# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 to add Series and Subseries to the title

module Ngao
  module Arclight
    class DocumentCollectionHierarchyComponent < ::Arclight::DocumentCollectionHierarchyComponent
      def level_label(content)
        return content unless %w[Series Subseries].include?(document.level)

        level = "#{document.level}: "
        level_html = "<span class=\"text-nowrap\">#{level}</span>"
        return "#{level_html}#{content}".html_safe unless content.start_with?('<a')

        doc = Nokogiri::HTML.fragment(content)
        link_element = doc.at_css('a')
        original_content = link_element.content
        link_element.content = ''
        link_element.add_child("#{level_html}#{original_content}")

        doc.to_html.html_safe
      end
    end
  end
end
