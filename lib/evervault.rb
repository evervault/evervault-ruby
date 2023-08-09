require "time"
require_relative "evervault/version"
require_relative "evervault/client"
require_relative "evervault/errors/errors"
require_relative "evervault/utils/validation_utils"

module Evervault
  class << self
    attr_accessor :app_id
    attr_accessor :api_key

    def encrypt(data)
      client.encrypt(data)
    end

    def decrypt(data)
      client.decrypt(data)
    end

    def run(function_name, encrypted_data, options = {})
      client.run(function_name, encrypted_data, options)
    end

    def enable_outbound_relay(decryption_domains = nil)
      client.enable_outbound_relay(decryption_domains)
    end

    def create_run_token(function_name, data = {})
      client.create_run_token(function_name, data)
    end

    def create_client_side_decrypt_token(data = nil, expiry = nil)
      if expiry != nil
        expiry = (expiry.to_f * 1000).to_i
      end
      client.create_token("decrypt:api", data, expiry)
    end

    private def client
      Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key(app_id, api_key)
      @client ||= Evervault::Client.new(app_uuid: app_id, api_key: api_key)
    end
  end
end
