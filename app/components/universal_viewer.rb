# frozen_string_literal: true

class UniversalViewer < ViewComponent::Base
  def initialize(document:, presenter:, **kwargs)
    super

    @document = document
    @presenter = presenter
  end

  def render?
    resources.any?
  end

  def manifest_url
    @resources&.first&.href
  end

  def resources
    @resources ||= @document.digital_objects || []
  end

  def uv_host
    ENV['UV_HOST']
  end

  def uv_config_host
    ENV['UV_CONFIG_HOST']
  end
end
