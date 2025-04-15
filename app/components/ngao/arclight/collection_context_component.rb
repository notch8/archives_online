# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 to add collection_id to the collection context

module Ngao
  module Arclight
    class CollectionContextComponent < ::Arclight::CollectionContextComponent
      def collection_info
        render Ngao::Arclight::CollectionInfoComponent.new(collection: collection)
      end
    end
  end
end
