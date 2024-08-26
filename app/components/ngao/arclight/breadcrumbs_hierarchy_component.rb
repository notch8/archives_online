# frozen_string_literal: true

# Using inheritance to override the initialize method to add the campus

module Ngao
  module Arclight
    class BreadcrumbsHierarchyComponent < ::Arclight::BreadcrumbsHierarchyComponent
      include CampusHelper

      def initialize(presenter:)
        super

        @campus = add_campus_link(presenter.document)
      end

      private

      def add_campus_link(document)
        campus_name = content_tag(:span, convert_campus_id(document.campus))
        search_query = "/?f[campus_unit_sim][]=#{document.campus}&q=&search_field=all_fields"
        link_to(campus_name, search_query)
      end
    end
  end
end
