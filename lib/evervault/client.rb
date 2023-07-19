require_relative "http/request"
require_relative "http/request_handler"
require_relative "http/request_intercept"
require_relative "http/relay_outbound_config"
require_relative "threading/repeated_timer"
require_relative "crypto/client"

module Evervault
  class Client

    attr_accessor :api_key, :base_url, :cage_run_url, :request_timeout
    def initialize(
      app_uuid:,
      api_key:,
      base_url: "https://api.evervault.com/",
      cage_run_url: "https://run.evervault.com/",
      relay_url: "https://relay.evervault.com:8443",
      ca_host: "https://ca.evervault.com",
      request_timeout: 30,
      curve: 'prime256v1'
    )
      @request = Evervault::Http::Request.new(timeout: request_timeout, app_uuid: app_uuid, api_key: api_key)
      @intercept = Evervault::Http::RequestIntercept.new(
        request: @request, ca_host: ca_host, api_key: api_key, base_url: base_url, relay_url: relay_url
      )
      @request_handler =
        Evervault::Http::RequestHandler.new(
          request: @request, base_url: base_url, cage_run_url: cage_run_url, cert: @intercept
        )
      @crypto_client = Evervault::Crypto::Client.new(request_handler: @request_handler, curve: curve)
      @intercept.setup()
    end

    def encrypt(data)
      @crypto_client.encrypt(data)
    end

    def run(function_name, encrypted_data, options = {})
      @request_handler.post(function_name, encrypted_data, options: options, cage_run: true)
    end

    def decrypt(data)
      raise Evervault::Errors::ArgumentError.new(
          "data must be of type Hash"
        ) if !(data.instance_of?(Hash))

      @request_handler.post("decrypt", data)
    end

    def enable_outbound_relay(decryption_domains = nil)
      if decryption_domains.nil?
        @intercept.setup_outbound_relay_config
      else
        @intercept.setup_decryption_domains(decryption_domains)
      end
    end

    def create_run_token(function_name, data = {})
      @request_handler.post("v2/functions/#{function_name}/run-token", data)
    end
  end
end
