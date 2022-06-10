require_relative "http/request"
require_relative "crypto/client"
require_relative "models/cage_list"

module Evervault
  class Client

    attr_accessor :api_key, :base_url, :cage_run_url, :request_timeout
    def initialize(
      api_key:,
      base_url: "https://api.evervault.com/",
      cage_run_url: "https://cage.run/",
      request_timeout: 30,
      curve: 'secp256k1'
    )
      @api_key = api_key
      @base_url = base_url
      @cage_run_url = cage_run_url
      @curve = curve
      @request =
        Evervault::Http::Request.new(
          api_key: api_key,
          timeout: request_timeout,
          base_url: base_url,
          cage_run_url: cage_run_url
        )
      @crypto_client = Evervault::Crypto::Client.new(request: @request, curve: @curve)
    end

    def encrypt(data)
      @crypto_client.encrypt(data)
    end

    def run(cage_name, encrypted_data, options = {})
      @request.post(cage_name, encrypted_data, options: options, cage_run: true)
    end

    def encrypt_and_run(cage_name, data, options = {})
      encrypted_data = encrypt(data)
      run(cage_name, encrypted_data, options)
    end

    def cages
      cage_list.to_hash
    end

    def cage_list
      cages = @request.get("cages")
      @cage_list ||= Evervault::Models::CageList.new(cages: cages["cages"], request: @request)
    end
  end
end
