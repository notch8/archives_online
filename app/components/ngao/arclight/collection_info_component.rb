# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 to remove collection_id from the dropdown

module Ngao
  module Arclight
    class CollectionInfoComponent < ::Arclight::CollectionInfoComponent
    end
  end
end
