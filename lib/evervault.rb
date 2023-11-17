# frozen_string_literal: true

require 'time'
require_relative 'evervault/version'
require_relative 'evervault/client'
require_relative 'evervault/errors/errors'
require_relative 'evervault/utils/validation_utils'

module Evervault
  class << self
    attr_accessor :app_id, :api_key

    def encrypt(...)
      client.encrypt(...)
    end

    def decrypt(...)
      client.decrypt(...)
    end

    def run(...)
      client.run(...)
    end

    def enable_outbound_relay(...)
      client.enable_outbound_relay(...)
    end

    def create_run_token(...)
      client.create_run_token(...)
    end

    def create_client_side_decrypt_token(data, expiry = nil)
      expiry = (expiry.to_f * 1000).to_i unless expiry.nil?
      client.create_token('api:decrypt', data, expiry)
    end

    private

    def client
      @client ||= begin
        Evervault::Utils::ValidationUtils.validate_app_uuid_and_api_key(app_id, api_key)
        Evervault::Client.new(app_uuid: app_id, api_key: api_key)
      end
    end
  end
end
