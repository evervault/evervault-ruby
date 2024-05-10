# frozen_string_literal: true

require_relative 'http/request'
require_relative 'http/request_handler'
require_relative 'http/request_intercept'
require_relative 'http/relay_outbound_config'
require_relative 'threading/repeated_timer'
require_relative 'crypto/client'

module Evervault
  class Client
    attr_accessor :config

    def initialize(app_uuid:, api_key:, **options, &block)
      @config = Evervault::Config.new(app_id: app_uuid, api_key: api_key)
      configure_via_options(**options) if options.any?
      intercept.setup
      configure(&block) if block_given?
    end

    def encrypt(data, role = nil)
      crypto_client.encrypt(data, role)
    end

    def decrypt(data)
      unless data.is_a?(String) || data.is_a?(Array) || data.is_a?(Hash)
        raise Evervault::Errors::EvervaultError, 'data is of invalid type'
      end

      payload = { data: data }
      response = request_handler.post('decrypt', payload, true, Evervault::Errors::ErrorMap)
      response['data']
    end

    def create_token(action, data, expiry = nil)
      payload = { payload: data, expiry: expiry, action: action }
      request_handler.post('client-side-tokens', payload, true, Evervault::Errors::ErrorMap)
    end

    def run(function_name, payload)
      payload = { payload: payload }
      res = request_handler.post("functions/#{function_name}/runs", payload, true, Evervault::Errors::ErrorMap)

      return res if res['status'] == 'success'

      Evervault::Errors::ErrorMap.raise_function_error_on_failure(res)
    end

    def create_run_token(function_name, data = {})
      request_handler.post("v2/functions/#{function_name}/run-token", data)
    end

    def enable_outbound_relay(decryption_domains = nil)
      if decryption_domains.nil?
        intercept.setup_outbound_relay_config
      else
        intercept.setup_decryption_domains(decryption_domains)
      end
    end

    def configure
      yield(config)
    end

    private

    def request
      @request || Evervault::Http::Request.new(config: config)
    end

    def intercept
      @intercept || Evervault::Http::RequestIntercept.new(request: request, config: config)
    end

    def request_handler
      @request_handler || Evervault::Http::RequestHandler.new(request: request, config: config, cert: intercept)
    end

    def crypto_client
      @crypto_client || Evervault::Crypto::Client.new(request_handler: request_handler, config: config)
    end

    def configure_via_options(**options)
      warn '[DEPRECATION] configuration via Evervault::Client.new arguments is deprecated. Pass a block or use the'\
      '`.configure` instead.'

      options.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
end
