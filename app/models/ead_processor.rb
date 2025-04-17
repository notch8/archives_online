# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class EadProcessor
  require 'zip'

  # calls all the methods
  def self.import_eads(args = {})
    process_files(args)
  end

  def self.import_updated_eads(args = {})
    process_updated_files(args)
  end

  # sets the url
  def self.client(args = {})
    args[:url] || ENV['ASPACE_EXPORT_URL'] || 'http://localhost/assets/ead_export/'
  end

  # Open web address with Nokogiri
  def self.page(args = {})
    Nokogiri::HTML(URI.open(client(args))) # rubocop:disable Security/Open
  end

  # open file and call extract
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.process_files(args = {})
    page(args).css('a').each do |file_link|
      file_name = file_link.attributes['href'].value
      link = client(args) + file_name
      directory = File.basename(file_name, File.extname(file_name))
      ext = File.extname(file_name)
      next unless ext == '.zip'
      next unless should_process_file(args, directory)

      URI.open(link, 'rb') do |file| # rubocop:disable Security/Open
        directory = directory.parameterize.underscore
        extract_and_index(file, directory)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def self.process_updated_files(args = {})
    page(args).css('a').each do |file_link|
      file_name = file_link.attributes['href'].value
      file_name.slice! client(args)
      repository = File.dirname(file_name)
      file = File.basename(file_name)
      ext = File.extname(file_name)
      next unless ext == '.xml'

      args = { ead: file, repository: repository }
      EadProcessor.index_single_ead(args)
    end
  end

  # unzip the file and call index
  # rubocop:disable Metrics/MethodLength
  def self.extract_and_index(file, directory)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        path = "./data/#{directory}"
        FileUtils.mkdir_p path
        fpath = File.join(path, f.name)
        FileUtils.rm_f(fpath)
        filename = File.basename(fpath)
        zip_file.extract(f, fpath)
        add_ead_to_db(filename, directory)
        add_last_indexed(filename, DateTime.now)
        EadProcessor.save_ead_for_downloading(fpath)
        EadProcessor.convert_ead_to_html(fpath)
        EadProcessor.delay.index_file(fpath, directory)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # for indexing a single ead file
  # need to unzip parent and index only the file selected
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.index_single_ead(args = {})
    repository = args[:repository]
    file_name = args[:ead]
    link = client(args) + "#{repository}/#{file_name}"
    directory = repository.parameterize.underscore
    path = "./data/#{directory}"
    FileUtils.mkdir_p(path)
    puts link
    download = URI.open(link, 'rb') # rubocop:disable Security/Open
    fpath = File.join(path, file_name)
    IO.copy_stream(download, fpath)
    filename = File.basename(fpath)
    add_last_indexed(filename, DateTime.now)
    EadProcessor.save_ead_for_downloading(fpath)
    EadProcessor.convert_ead_to_html(fpath)
    EadProcessor.delay.index_file(fpath, repository)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # for deleting a single ead file
  def self.delete_single_ead(args = {})
    filename = args[:ead]
    ENV['FILE'] = filename
    system('bundle exec rake ngao:delete_ead', exception: true)
    # FIXME: In production deployment, the row isn't being destroyed by the rake task
    #  so try a direct invocation of the remove_ead_from_db method
    remove_ead_from_db(filename)
  end

  # extract file
  def self.extract_file(file, directory)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        path = "./data/#{directory}"
        FileUtils.mkdir_p path
        fpath = File.join(path, f.name)
        File.delete(fpath) if File.exist?(fpath)
        zip_file.extract(f, fpath)
      end
    end
  end

  # index a file
  def self.index_file(filename, repository)
    ENV['REPOSITORY_ID'] = repository
    ENV['FILE'] = filename
    system('bundle exec rake arclight:index', exception: true)
  end

  # get list of zip files and ead contents to show on admin import page
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.get_repository_names(args = {})
    repositories = {}
    page(args).css('a').each do |repository|
      name = repository.attributes['href'].value
      link = client(args) + name
      ext = File.extname(name)
      key = File.basename(name, File.extname(name))
      next unless ext == '.zip'

      value = { name: repository.children.text }
      repositories[key] = value
      last_updated_at = DateTime.parse(repository.next_sibling.text)
      update_repository(key, value[:name], last_updated_at)
      eads = []
      if ext == '.zip'
        URI.open(link, 'rb') do |file| # rubocop:disable Security/Open
          eads = get_ead_names(file, key)
        end
      end
      repositories[key][:eads] = eads
    end
    repositories
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # Only updates name & last update date w/ data from aspace
  def self.update_repository(id, name, last_updated_at)
    repo = Repository.find_by(repository_id: id)
    repo.update_attributes(name: name, last_updated_at: last_updated_at)
  end

  # get list of eads contained in zip file
  def self.get_ead_names(file, repository)
    eads = []
    Zip::File.open(file) do |zip_file|
      zip_file.each do |entry|
        if entry.file?
          eads << entry.name
          add_ead_to_db(entry.name, repository)
        end
      end
    end
    eads
  end

  # get list of eads in solr and postgres but no longer on archive space
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.get_delta_eads(args = {})
    archive_space_eads = []
    page(args).css('a').each do |ead|
      name = ead.attributes['href'].value
      ext = File.extname(name)
      name = File.basename(name, File.extname(name))
      next unless ext == '.xml'

      ead_filename = name + ext
      archive_space_eads << ead_filename
    end
    local_eads = Ead.all.collect.each(&:filename)
    delta_eads = local_eads - archive_space_eads
    delta_eads.uniq.sort
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def self.add_ead_to_db(filename, repository_id)
    Ead.where(filename: filename).first_or_create do |ead|
      ead.repository = Repository.find_by(repository_id: repository_id)
    end
  end

  def self.remove_ead_from_db(filename)
    Ead.find_by(filename: filename)&.destroy
  end

  def self.add_last_indexed(filename, indexed_at)
    Ead.find_by(filename: filename)&.update_attributes(last_indexed_at: indexed_at)
  end

  def self.add_last_updated(filename, updated_at)
    Ead.find_by(filename: filename)&.update_attributes(last_updated_at: updated_at)
  end

  def self.get_updated_eads(args = {})
    page(args).css('a').each do |ead|
      name = ead.attributes['href'].value
      ext = File.extname(name)
      name = File.basename(name, File.extname(name))
      next unless ext == '.xml'

      ead_filename = name + ext
      ead_last_updated_at = DateTime.parse(ead.next_sibling.text)
      add_last_updated(ead_filename, ead_last_updated_at)
    end
  end

  # copies ead to public directory for downloading
  def self.save_ead_for_downloading(file)
    directory = './public/ead'
    FileUtils.mkdir_p directory
    doc = Nokogiri::XML(File.read(file))
    filename = doc.xpath('//*[local-name()="eadid"]').first&.text || file
    filename = filename == file ? file : "#{filename}.xml"
    fpath = File.join(directory, filename)
    File.delete(fpath) if File.exist?(fpath)
    FileUtils.cp(file, fpath)
  end

  # converts the saved ead to html and saves in public directory for downloading
  def self.convert_ead_to_html(file)
    directory = './public/html'
    FileUtils.mkdir_p directory
    xslt = Nokogiri::XSLT(File.read('app/templates/template.xslt'))
    doc = Nokogiri::XML(File.read(file))
    # ensure filename matches id
    filename = doc.xpath('//*[local-name()="eadid"]').first&.text || File.basename(file, '.xml')
    doc.remove_namespaces!
    File.write("public/html/#{filename}.html", xslt.transform(doc))
  end

  # check if should process file
  # if args are nil, process all zip files
  # otherwise, only process the specified file
  def self.should_process_file(args, name)
    args[:files].nil? || args[:files].include?(name)
  end
end
# rubocop:enable Metrics/ClassLength
