# frozen_string_literal: true

# OVERRIDE adds a custom role-specific label to the creator field
module Ngao
  module Blacklight
    class CreatorRoleComponent < ::Blacklight::MetadataFieldComponent
      def label
        values = @field.values
        # values is an array containing a JSON string with one or more hash elements
        # with multiple values possible for each role.
        # ["[{\"Interviewer\":[\"Stahlman, Joseph\"]}]"]
        creators_with_roles = JSON.parse(values.first)
        labels = creators_with_roles.map(&:keys).flatten
        # we can only show one label, so if there are multiple roles, we just use default
        label = labels.first if labels.size == 1
        return super unless label

        "#{label}:"
      end
    end
  end
end
