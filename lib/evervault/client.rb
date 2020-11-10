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

    def run(cage_name, encrypted_data, options = {})
      headers = build_cage_run_headers(options)
      @request.post(cage_name, encrypted_data, optional_headers: headers, cage_run: true)
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

    private def build_cage_run_headers(options)
      optional_headers = {}
      if options.key?(:async)
        if options[:async] == true
          optional_headers[:"x-async"] = "true"
        end
        options.delete(:async)
      end
      if options.key?(:version)
        if options[:version].is_a? Integer
          optional_headers[:"x-version-id"] = options[:version].to_s
        end
        options.delete(:version)
      end
      optional_headers.merge(options)
    end
  end
end
