# frozen_string_literal: true

# OVERRIDE Arclight v1.4.0 helper methods

module ArclightHelperDecorator
  def repository_collections_path(repository)
    search_action_url(
      f: {
        repository_ssim: [repository.name],
        level_ssim: ['Collection']
      },
      group: true
    )
  end
end

ArclightHelper.prepend(ArclightHelperDecorator)
