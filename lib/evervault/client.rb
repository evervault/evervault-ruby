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
      api_key:,
      base_url: "https://api.evervault.com/",
      cage_run_url: "https://run.evervault.com/",
      relay_url: "https://relay.evervault.com:8443",
      ca_host: "https://ca.evervault.com",
      request_timeout: 30,
      curve: 'prime256v1'
    )
      @request = Evervault::Http::Request.new(timeout: request_timeout, api_key: api_key)
      @intercept = Evervault::Http::RequestIntercept.new(
        request: @request, ca_host: ca_host, api_key: api_key, relay_url: relay_url
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

    def relay(decryption_domains=[])
      @intercept.setup_domains(decryption_domains)
    end

    def create_run_token(function_name, data)
      @request_handler.post("v2/functions/#{function_name}/run-token", data)
    end
  end
end
