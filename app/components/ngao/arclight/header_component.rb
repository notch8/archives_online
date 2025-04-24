# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0
# - Add a nav link to the Masthead text

module Ngao
  module Arclight
    class HeaderComponent < ::Arclight::HeaderComponent
      def masthead
        render Ngao::Arclight::MastheadComponent.new
      end
    end
  end
end
