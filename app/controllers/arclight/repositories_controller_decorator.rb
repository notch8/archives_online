# frozen_string_literal: true

# OVERRIDE: Arclight v1.4.0 to add campus level
module Arclight
  module RepositoriesControllerDecorator
    def index
      super
      set_campuses
    end

    private

    def set_campuses
      @campuses =
        @repositories.group_by(&:campus)
                     .sort do |a, b|
                       helpers.convert_campus_id(a.first).downcase <=> helpers.convert_campus_id(b.first).downcase
                     end
    end
  end
end

Arclight::RepositoriesController.prepend(Arclight::RepositoriesControllerDecorator)
