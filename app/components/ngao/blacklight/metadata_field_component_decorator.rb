# frozen_string_literal: true

# OVERRIDE Blacklight MetadataFieldComponentDecorator v8.3.0 to render custom labels when they exist
module Ngao
  module Blacklight
    module MetadataFieldComponentDecorator
      def label
        key = @field.key
        document = @field.document
        heading_field = "#{key}_heading_ssm"

        label = document[heading_field]&.first
        return super unless label

        "#{label}:"
      end
    end
  end
end

Blacklight::MetadataFieldComponent.prepend(Ngao::Blacklight::MetadataFieldComponentDecorator)
