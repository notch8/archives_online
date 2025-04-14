# frozen_string_literal: true

# OVERRIDE Blacklight v8.3.0 - [i97] - Start Over Button should return the user
# back to the home page instead of performing an empty search.

module Blacklight
  module StartOverButtonComponentDecorator
    private

    def start_over_path
      root_path
    end
  end
end

Blacklight::StartOverButtonComponent.prepend(Blacklight::StartOverButtonComponentDecorator)
