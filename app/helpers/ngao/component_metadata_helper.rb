# frozen_string_literal: true

module Ngao
  # Helper methods for determining component metadata presence
  module ComponentMetadataHelper
    # Checks if a SolrDocument for an archival component has metadata fields
    # populated beyond title and containers, based on configured component fields.
    #
    # @param document [SolrDocument]
    # @param blacklight_config [Blacklight::Configuration]
    # @return [Boolean]
    def component_has_extra_metadata?(document, blacklight_config)
      blacklight_config.component_fields.values.any? do |field_config|
        next false if field_config.accessor == :containers || field_config.field == :containers

        field_name = solr_field_name_for_config(field_config)
        next false unless field_name

        field_value_present?(document, field_name)
      end
    end

    private

    # Determines the Solr field name to check based on the field configuration.
    # @param field_config [Blacklight::Configuration::Field]
    # @return [String, Symbol, nil]
    def solr_field_name_for_config(field_config)
      field_config.field || (if field_config.accessor.is_a?(String) || field_config.accessor.is_a?(Symbol)
                               field_config.accessor
                             end)
    end

    # Checks if the document has the specified field and if the value is present and non-empty.
    # Handles single values, arrays, nil, and empty strings gracefully.
    # @param document [SolrDocument]
    # @param field_name [String, Symbol]
    # @return [Boolean]
    def field_value_present?(document, field_name)
      value = document[field_name.to_s]

      value.present? &&
        (!value.respond_to?(:all?) || value.all?(&:present?))
    end
  end
end
