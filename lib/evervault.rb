require_relative "evervault/version"
require_relative "evervault/client"
require_relative "evervault/errors/errors"

module Evervault
  class << self
    attr_accessor :api_key

    def run(cage_name, encrypted_data)
      client.run(cage_name, encrypted_data)
    end

    def encrypt_and_run(cage_name, data)
      client.encrypt_and_run(cage_name, data)
    end

    def encrypt(data)
      client.encrypt(data)
    end

    def cages
      client.cages
    end

    def cage_list
      client.cage_list
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
