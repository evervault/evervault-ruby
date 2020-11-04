require_relative "evervault/version"
require_relative "evervault/client"
require_relative "evervault/errors/errors"

module Evervault
  class << self
    attr_accessor :api_key

    def method_missing(method, *args, &block)
      client.send(method, *args, &block)
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
