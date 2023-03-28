require_relative "evervault/version"
require_relative "evervault/client"
require_relative "evervault/errors/errors"

module Evervault
  class << self
    attr_accessor :api_key

    def encrypt(data)
      client.encrypt(data)
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

    private def client
      if api_key.nil?
        raise Evervault::Errors::AuthenticationError.new(
                "Please enter your team's API Key"
              )
      end
      @client ||= Evervault::Client.new(api_key: api_key)
    end
  end
end
