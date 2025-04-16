# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 to add collection_id to the collection context
#   and to render the `Ngao::Arclight::DocumentDownloadComponent`

module Ngao
  module Arclight
    class SidebarComponent < ::Arclight::SidebarComponent
      def collection_context
        render Ngao::Arclight::CollectionContextComponent.new(
          presenter: document_presenter(document),
          download_component: Ngao::Arclight::DocumentDownloadComponent
        )
      end
    end
  end
end
