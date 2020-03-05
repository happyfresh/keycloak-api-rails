module Keycloak
  class PublicKeyCachedResolver
    attr_reader :cached_public_key_retrieved_at

    def initialize(http_client, realm_id, public_key_cache_ttl)
      @resolver                       = PublicKeyResolver.new(http_client, realm_id)
      @public_key_cache_ttl           = public_key_cache_ttl
      @cached_public_keys             = nil
      @cached_public_key_retrieved_at = nil
    end

    def self.from_configuration(http_client, configuration)
      PublicKeyCachedResolver.new(http_client, configuration.realm_id, configuration.public_key_cache_ttl)
    end

    def find_public_keys
      if public_keys_are_outdated?
        @cached_public_keys             = @resolver.find_public_keys
        @cached_public_key_retrieved_at = Time.now
      end
      @cached_public_keys
    end

    private

    def public_keys_are_outdated?
      @cached_public_keys.nil? || @cached_public_key_retrieved_at.nil? || Time.now > (@cached_public_key_retrieved_at + @public_key_cache_ttl.seconds)
    end
  end
end
