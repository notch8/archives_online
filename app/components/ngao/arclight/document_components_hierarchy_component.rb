# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 in Ngao namespace
# - Accept expand_all parameter
# - Modify paginate? to respect expand_all

module Ngao
  module Arclight
    class DocumentComponentsHierarchyComponent < ::Arclight::DocumentComponentsHierarchyComponent
      # Explicitly include Turbo helper for turbo_frame_tag
      include Turbo::FramesHelper

      # rubocop:disable Metrics/ParameterLists
      def initialize(document: nil, target_index: -1, minimum_pagination_size: 20, left_outer_window: 3,
                     maximum_left_gap: 10, window: 10, expand_all: false)

        super(
          document: document,
          target_index: target_index,
          minimum_pagination_size: minimum_pagination_size,
          left_outer_window: left_outer_window,
          maximum_left_gap: maximum_left_gap,
          window: window
        )

        @expand_all = expand_all
      end
      # rubocop:enable Metrics/ParameterLists

      # Modify paginate? to check @expand_all
      def paginate?
        return false if @expand_all

        @document.number_of_children > @minimum_pagination_size
      end

      # Modify hierarchy_path to include expand_all if needed
      def hierarchy_path(**args)
        path_params = args.dup
        path_params[:hierarchy] = true
        path_params[:expand_all] = true if @expand_all && !paginate?
        path_params.delete(:expand_all) if !@expand_all || paginate?

        helpers.hierarchy_solr_document_path(id: @document.id, **path_params)
      end

      private

      # Ensure helpers are available if needed (e.g., for url_for in hierarchy_path)
      def helpers
        @view_context
      end
    end
  end
end
