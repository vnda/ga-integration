# frozen_string_literal: true

require "raven"

Raven.configure do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.release = ENV["APP_REVISION"] || "dev"
  config.environments = %w[development staging production]
  config.current_environment = ENV["SENTRY_ENV"] || "development"
end
