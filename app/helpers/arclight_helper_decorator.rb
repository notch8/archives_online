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

  def render_creator_links(field)
    # values is an array containing a JSON string with one or more hash elements
    # with multiple values possible for each role.
    # ["[{\"Interviewer\":[\"Stahlman, Joseph\"]}]"]
    values = field[:value]
    creators_with_roles = JSON.parse(values.first)
    creators = creators_with_roles.map(&:values).flatten
    link_to_name_facet({ config: config, value: creators })
  end
end

ArclightHelper.prepend(ArclightHelperDecorator)
