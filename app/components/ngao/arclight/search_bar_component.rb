# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0
# - Set Grouped By Collection as the default search result filter
# - Remove 'this collection' from dropdown options when selection is not available.

module Ngao
  module Arclight
    class SearchBarComponent < ::Arclight::SearchBarComponent
      # OVERRIDE Arclight v1.4.0 to set Grouped By Collection as the default search result filter
      def initialize(**args)
        params = args[:params] || {}
        super(**args, params: params.merge({ group: true }))
      end

      # OVERRIDE Arclight v1.4.0 to remove 'this collection' from dropdown options
      # when this selection is not available.
      def within_collection_options
        all_collections_option = [t('arclight.within_collection_dropdown.all_collections'), '']

        if collection_name.present?
          this_collection_option = [t('arclight.within_collection_dropdown.this_collection'), collection_name]
          options = [this_collection_option, all_collections_option]
          selected_value = collection_name
        else
          options = [all_collections_option]
          selected_value = ''
        end

        helpers.options_for_select(options, selected_value)
      end
    end
  end
end
