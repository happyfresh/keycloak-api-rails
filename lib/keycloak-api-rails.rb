require "logger"
require "json/jwt"
require "uri"
require "date"

require_relative "keycloak-api-rails/configuration"
require_relative "keycloak-api-rails/token_error"
require_relative "keycloak-api-rails/helper"
require_relative "keycloak-api-rails/public_key_resolver"
require_relative "keycloak-api-rails/public_key_cached_resolver"
require_relative "keycloak-api-rails/service"
require_relative "keycloak-api-rails/middleware"
require_relative "keycloak-api-rails/railtie" if defined?(Rails)

module Keycloak

  def self.configure
    yield @configuration ||= Keycloak::Configuration.new
  end

  def self.config
    @configuration
  end

  def self.service
    @service ||= Keycloak::Service.new(PublicKeyCachedResolver.from_configuration(config))
  end

  def self.logger
    config.logger
  end

  def self.load_configuration
    configure do |config|
      config.server_url                             = nil
      config.realm_id                               = nil
      config.logger                                 = ::Logger.new(STDOUT)
      config.skip_paths                             = {}
      config.token_expiration_tolerance_in_seconds  = 10
      config.public_key_cache_ttl                   = 86400
    end
  end

  load_configuration
end