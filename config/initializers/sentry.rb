# frozen_string_literal: true

require 'sentry-ruby'
require 'sentry-sidekiq'

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger, :sentry_logger]
  config.environment = ENV['SENTRY_ENVIRONMENT']
  config.debug = true
end