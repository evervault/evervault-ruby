require "openssl"
require "pry"

module Evervault
  module Crypto
    class Key
      attr_reader :public_key
      def initialize(public_key:)
        @public_key = OpenSSL::PKey::RSA.new(format_key(public_key))
      end

      private def format_key(key)
        key_header = "-----BEGIN PUBLIC KEY-----\n"
        key_footer = "-----END PUBLIC KEY-----"
        return key if key.include?(key_header) && key.include?(key_footer)
        "#{key_header}#{key.scan(/.{0,64}/).join("\n")}#{key_footer}"
      end
    end
  end
end
