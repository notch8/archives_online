# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 to add Series and Subseries to the title and handle expand all

module Ngao
  module Arclight
    class DocumentCollectionHierarchyComponent < ::Arclight::DocumentCollectionHierarchyComponent
      # OVERRIDE: Check for @expand_all from controller, otherwise use default behavior
      def show_expanded?
        controller_wants_expanded = @view_context.instance_variable_get(:@expand_all) == true

        if controller_wants_expanded
          true
        else
          super
        end
      end

      def level_label(content)
        return content unless %w[Series Subseries].include?(document.level)

        level = "#{document.level}: "
        level_html = "<span class=\"text-nowrap text-muted\">#{level}</span>"
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
