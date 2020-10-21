require_relative "http/request"
require_relative "crypto/client"

module Evervault
  class Client
    def self.setup
      new.tap { |instance| yield(instance) if block_given? }
    end

    attr_accessor :api_key, :base_url, :cage_run_url, :request_timeout
    def initialize(
      api_key:,
      base_url: "https://api.evervault.com/",
      cage_run_url: "https://cage.run/",
      request_timeout: 30
    )
      @api_key = api_key
      @base_url = base_url
      @cage_run_url = cage_run_url
      @request =
        Evervault::Http::Request.new(
          api_key: api_key,
          timeout: request_timeout,
          base_url: base_url,
          cage_run_url: cage_run_url
        )
      @crypto_client = Evervault::Crypto::Client.new(request: @request)
    end

    def encrypt(data)
      @crypto_client.encrypt(data)
    end

    def run(cage_name, encrypted_data)
      @request.post(cage_name, encrypted_data, cage_run: true)
    end

    def encrypt_and_run(cage_name, data)
      encrypted_data = encrypt(data)
      run(cage_name, encrypted_data)
    end

    def cages
      @request.get("cages")
    end
  end
end
