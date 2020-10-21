require_relative "../errors/errors"
require_relative "key"
require "openssl"
require "base64"
require "json"
require "securerandom"

module Evervault
  module Crypto
    class Client
      attr_reader :request
      def initialize(request:)
        @request = request
      end

      def encrypt(data)
        raise Evervault::Errors::UndefinedDataError.new(
          "Data is required for encryption"
        ) if data.nil? || data.empty?
          
        if data.instance_of? Hash
          encrypt_hash(data)
        elsif encryptable_data?(data)
          encrypt_string(data)
        end
      end

      private def encrypt_string(data)
        cipher = OpenSSL::Cipher::AES256.new(:GCM).encrypt
        iv = cipher.random_iv
        root_key = cipher.random_key
        cipher.key = root_key
        cipher.iv = iv
        encrypted_data = cipher.update(data) + cipher.final
        encrypted_buffer = encrypted_data + cipher.auth_tag
        encrypted_key =
          team_key.public_key.public_encrypt(
            root_key,
            OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING
          )
        data = [encrypted_key, encrypted_buffer, iv].map { |val| Base64.strict_encode64(val) }
        format(header_type(data), *data)
      end

      private def encrypt_hash(data)
        if encryptable_data?(data)
          return encrypt_string(data)
        elsif data.instance_of?(Hash)
          encrypted_data = {}
          data.each { |key, value| encrypted_data[key] = encrypt_hash(value) }
          return encrypted_data
        end
        data
      end

      private def encryptable_data?(data)
        data.instance_of?(String) || data.instance_of?(Array) ||
          [true, false].include?(data) || data.instance_of?(Integer) ||
          data.instance_of?(Float)
      end

      private def team_key
        @team_key ||= Key.new(public_key: @request.get("cages/key")["key"])
      end

      private def format(header, encrypted_key, encrypted_data, iv)
        header =
          utf8_to_base_64_url(
            { iss: "evervault", version: 1, datatype: header }.to_json
          )
        payload =
          utf8_to_base_64_url(
            {
              cageData: encrypted_key,
              keyIv: iv,
              sharedEncryptedData: encrypted_data
            }.to_json
          )
        "#{header}.#{payload}.#{SecureRandom.uuid}"
      end

      private def utf8_to_base_64_url(data)
        b64_string = Base64.strict_encode64(data)
        b64_string.gsub("+", "-").gsub("/", "_")
      end

      private def header_type(data)
        if data.instance_of?(Array)
          return "Array"
        elsif [true, false].include?(data)
          return "boolean"
        elsif data.instance_of?(Hash)
          return "object"
        elsif data.instance_of?(Float) || data.instance_of?(Integer)
          return "number"
        elsif data.instance_of?(String)
          return "string"
        end
      end
    end
  end
end
