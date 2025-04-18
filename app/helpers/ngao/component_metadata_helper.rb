# frozen_string_literal: true

module Ngao
  # Helper methods for determining component metadata presence
  module ComponentMetadataHelper
    # Checks if a SolrDocument or Presenter for an archival component has metadata fields
    # populated beyond title and containers, based on configured component fields.
    #
    # @param document [SolrDocument, Blacklight::DocumentPresenter]
    # @param blacklight_config [Blacklight::Configuration]
    # @return [Boolean]
    def component_has_extra_metadata?(document, blacklight_config)
      blacklight_config.component_fields.values.any? do |field_config|
        next false if field_is_container?(field_config)

        field_name = extract_field_name(field_config)
        next false unless field_name

        check_document_field(document, field_name)
      end
    end

    private

    def field_is_container?(field_config)
      field_config.try(:accessor) == :containers || field_config.try(:field) == :containers
    end

    def extract_field_name(field_config)
      field_name = field_config.try(:field)
      return field_name if field_name

      accessor = field_config.try(:accessor)
      accessor if accessor.is_a?(String) || accessor.is_a?(Symbol)
    end

    def check_document_field(document, field_name)
      doc_value = document[field_name.to_s]
      value_present_and_non_empty?(doc_value)
    rescue StandardError => e
      log_field_access_error(document, field_name, e)
      false
    end

    def value_present_and_non_empty?(value)
      value.present? && (!value.respond_to?(:all?) || value.all?(&:present?))
    end

    def log_field_access_error(document, field_name, error)
      Rails.logger.error(
        "[ComponentMetadataHelper] Error accessing field #{field_name} " \
        "on document #{document&.id}: #{error.message}"
      )
    end
  end
end
