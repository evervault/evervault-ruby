require_relative "http/request"
require_relative "http/request_handler"
require_relative "http/request_intercept"
require_relative "crypto/client"
require_relative "models/cage_list"

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

    def run(cage_name, encrypted_data, options = {})
      @request_handler.post(cage_name, encrypted_data, options: options, cage_run: true)
    end

    def encrypt_and_run(cage_name, data, options = {})
      encrypted_data = encrypt(data)
      run(cage_name, encrypted_data, options)
    end

    def cages
      cage_list.to_hash
    end

    def cage_list
      cages = @request_handler.get("cages")
      @cage_list ||= Evervault::Models::CageList.new(cages: cages["cages"], request: @request)
    end

    def relay(decryption_domains=[])
      @intercept.setup_domains(decryption_domains)
    end
  end
end
