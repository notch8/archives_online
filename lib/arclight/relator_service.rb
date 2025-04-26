# frozen_string_literal: true

require 'rdf'
require 'rdf/ntriples'

module Arclight
  class RelatorService
    attr_reader :graph

    def self.for(code)
      return nil if code.blank?

      @instance ||= new
      @instance.get_authoritative_label(code)
    end

    def initialize(file_path: default_file_path)
      @graph = RDF::Graph.load(file_path, format: :ntriples)
    end

    # Method to get the authoritativeLabel for a given code
    def get_authoritative_label(code)
      subject = RDF::URI("http://id.loc.gov/vocabulary/relators/#{code}")
      predicate = RDF::URI('http://www.loc.gov/mads/rdf/v1#authoritativeLabel')

      # Return the authoritativeLabel for the subject
      label = @graph.query([subject, predicate, nil]).first&.object
      return nil unless label

      label.to_s
    end

    private

    def default_file_path
      if defined?(Rails)
        Rails.root.join('config', 'relators.nt').to_s
      else
        File.expand_path('../../config/relators.nt', __dir__)
      end
    end
  end
end
