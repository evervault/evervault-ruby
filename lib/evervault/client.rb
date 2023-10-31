require_relative "http/request"
require_relative "http/request_handler"
require_relative "http/request_intercept"
require_relative "http/relay_outbound_config"
require_relative "threading/repeated_timer"
require_relative "crypto/client"

module Evervault
  class Client
    attr_reader :crypto_client

    def initialize(
      app_uuid:,
      api_key:,
      base_url: "https://api.evervault.com/",
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
          request: @request, base_url: base_url, cert: @intercept
        )
      @crypto_client = Evervault::Crypto::Client.new(request_handler: @request_handler, curve: curve)
      @intercept.setup()
    end

    def encrypt(data, role)
      crypto_client.encrypt(data, role)
    end

    def decrypt(data)
      unless data.is_a?(String) || data.is_a?(Array) || data.is_a?(Hash)
        raise Evervault::Errors::EvervaultError.new("data is of invalid type")
      end
      payload = { data: data }
      response = @request_handler.post("decrypt", payload, true, Evervault::Errors::ErrorMap)
      response["data"]
    end

    def create_token(action, data, expiry = nil)
      payload = { payload: data, expiry: expiry, action: action }
      @request_handler.post("client-side-tokens", payload, true, Evervault::Errors::ErrorMap)
    end

    def run(function_name, payload)
      payload = { payload: payload }
      res = @request_handler.post("functions/#{function_name}/runs", payload, true, Evervault::Errors::ErrorMap)
      
      if res["status"] == "success"
        return res
      else
        return Evervault::Errors::ErrorMap.raise_function_error_on_failure(res)
      end
    end

    def create_run_token(function_name, data = {})
      @request_handler.post("v2/functions/#{function_name}/run-token", data)
    end

    def enable_outbound_relay(decryption_domains = nil)
      if decryption_domains.nil?
        @intercept.setup_outbound_relay_config
      else
        @intercept.setup_decryption_domains(decryption_domains)
      end
    end
  end
end
