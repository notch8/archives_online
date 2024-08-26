# frozen_string_literal: true
# OVERRIDE blacklight (8.3.0) to set Grouped By Collection as the default search result filter

module Blacklight
  module SearchBarComponentDecorator
    def initialize(**args)
      params = args[:params] || {}
      super(**args, params: params.merge({ group: true }))
    end
  end
end

Blacklight::SearchBarComponent.prepend(Blacklight::SearchBarComponentDecorator)