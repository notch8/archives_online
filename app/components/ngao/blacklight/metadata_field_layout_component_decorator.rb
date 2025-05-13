# frozen_string_literal: true

# OVERRIDE Blacklight MetadataFieldLayoutComponentDecorator v8.3.0 to render custom labels when they exist
# When this component is initialized, `@key = @field.key.parameterize` is not splitting some of the keys properly

module Ngao
  module Blacklight
    module MetadataFieldLayoutComponentDecorator
      def label
        document = @field.document
        heading_field = "#{@key}_heading_ssm"

        label = document[heading_field]&.first

        # Some EADs are coming back with the key as the Solr label rather than just the key
        # For example, the "<odd>" EAD keys are coming back as "odd_html_tesm" rather than just "odd"
        unless label.present?
          heading_field = "#{@key.split('_').first}_heading_ssm"
          label = document[heading_field]&.first
        end

        return super unless label

        "#{label}:"
      end
    end
  end
end

Blacklight::MetadataFieldLayoutComponent.prepend(Ngao::Blacklight::MetadataFieldLayoutComponentDecorator)
