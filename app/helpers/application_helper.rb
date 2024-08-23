# frozen_string_literal: true

module ApplicationHelper
  include Blacklight::LocalePicker::LocaleHelper

  def additional_locale_routing_scopes
    [blacklight, arclight_engine]
  end

  def render_campus_name(args)
    key = args[:value] || []
    convert_campus_id(key[0])
  end

  def render_campus_facet(options = {})
    convert_campus_id(options)
  end
end
