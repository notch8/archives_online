# frozen_string_literal: true

module Arclight
  # OVERRIDE Arclight v1.4.0 
  # - Accept expand_all parameter
  # - Modify paginate? to respect expand_all
  class DocumentComponentsHierarchyComponent < ViewComponent::Base
    # rubocop:disable Metrics/ParameterLists
    # Add expand_all parameter
    def initialize(document: nil, target_index: -1, minimum_pagination_size: 20, left_outer_window: 3, maximum_left_gap: 10, window: 10, expand_all: false)
      super

      @document = document
      @target_index = target_index&.to_i || -1
      @minimum_pagination_size = minimum_pagination_size
      @left_outer_window = left_outer_window
      @maximum_left_gap = maximum_left_gap
      @window = window
      @expand_all = expand_all # Store the flag
    end
    # rubocop:enable Metrics/ParameterLists

    # Modify paginate? to check @expand_all
    def paginate?
      return false if @expand_all # Never paginate if expanding all

      @document.number_of_children > @minimum_pagination_size
    end

    # Modify hierarchy_path to include expand_all if needed
    def hierarchy_path(**kwargs)
      base_path = helpers.hierarchy_solr_document_path(id: @document.id, hierarchy: true, nest_path: params[:nest_path], **kwargs)
      if @expand_all
        separator = base_path.include?("?") ? "&" : "?"
        "#{base_path}#{separator}expand_all=true"
      else
        base_path
      end
    end
  end
end 