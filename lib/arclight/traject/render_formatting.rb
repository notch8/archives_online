# frozen_string_literal: true

module Arclight
  module Traject
    module RenderFormatting
      def physdesc_child_elements
        %w[
          dao
          daodesc
          dimensions
          extent
          physfacet
          physloc
        ]
      end

      def render_formatted_text(xpath, skip_elements: physdesc_child_elements)
        lambda do |record, accumulator, _context|
          record.xpath(xpath).each do |node|
            fragments = extract_fragments(node, skip_elements)
            accumulator << fragments.join(' ') unless fragments.empty?
          end
        end
      end

      private

      def extract_fragments(node, skip_elements)
        node.children.filter_map do |child|
          next if child.element? && skip_elements.include?(child.name)

          if child.element?
            format_known_element(child)
          elsif child.text?
            child.text.strip.presence
          end
        end
      end

      def format_known_element(node)
        return node.text.strip unless node.name == 'emph' || node.name == 'title'

        format_emphasis(node)
      end

      def format_emphasis(node)
        case node['render']
        when 'bold'
          "<strong>#{node.text.strip}</strong>"
        when 'italic'
          "<em>#{node.text.strip}</em>"
        when 'underline'
          "<u>#{node.text.strip}</u>"
        else
          node.text.strip
        end
      end
    end
  end
end
