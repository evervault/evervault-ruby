require_relative "../errors/errors"
require_relative "curves/p256"
require_relative "../version"
require "openssl"
require "base64"
require "json"
require "securerandom"

module Evervault
  module Crypto
    class Client
      attr_reader :request_handler
      def initialize(request_handler:, curve:)
        @curve = curve
        @p256 = Evervault::Crypto::Curves::P256.new()
        @ev_version = base_64_remove_padding(
            Base64.strict_encode64(EV_VERSION[curve])
        )
        response = request_handler.get("cages/key")
        key = @curve == 'secp256k1' ? 'ecdhKey' : 'ecdhP256Key'
        @team_key = response[key]
      end

      def encrypt(data)
        raise Evervault::Errors::UndefinedDataError.new(
          "Data is required for encryption"
        ) if data.nil? || (data.instance_of?(String) && data.empty?)

        raise Evervault::Errors::UnsupportedEncryptType.new(
          "Encryption is not supported for #{data.class}"
        ) if !(encryptable_data?(data) || data.instance_of?(Hash) || data.instance_of?(Array))
          
        traverse_and_encrypt(data)
      end

      private def encrypt_string(data_to_encrypt)
        cipher = OpenSSL::Cipher.new('aes-256-gcm').encrypt

        shared_key = generate_shared_key()
        cipher.key = shared_key

        iv = cipher.random_iv
        cipher.iv = iv

        if (@curve == 'prime256v1')
          cipher.auth_data = Base64.strict_decode64(@team_key)
        end

        encrypted_data = cipher.update(data_to_encrypt.to_s) + cipher.final + cipher.auth_tag

        ephemeral_key_compressed_string = @ephemeral_public_key.to_octet_string(:compressed)

        format(header_type(data_to_encrypt), Base64.strict_encode64(iv), Base64.strict_encode64(ephemeral_key_compressed_string), Base64.strict_encode64(encrypted_data))
      end

      private def traverse_and_encrypt(data)
        if encryptable_data?(data)
          return encrypt_string(data)
        elsif data.instance_of?(Hash)
          encrypted_data = {}
          data.each { |key, value| encrypted_data[key] = traverse_and_encrypt(value) }
          return encrypted_data
        elsif data.instance_of?(Array)
          encrypted_data = data.map { |value| traverse_and_encrypt(value) }
          return encrypted_data
        else
          raise Evervault::Errors::UnsupportedEncryptType.new(
            "Encryption is not supported for #{data.class}"
          )
        end
        data
      end

      private def encryptable_data?(data)
        data.instance_of?(String) || [true, false].include?(data) ||
        data.instance_of?(Integer) || data.instance_of?(Float)
      end

      private def generate_shared_key()
        ec = OpenSSL::PKey::EC.new(@curve)
        ec.generate_key
        @ephemeral_public_key = ec.public_key

        decoded_team_key = OpenSSL::BN.new(Base64.strict_decode64(@team_key), 2)
        group_for_team_key = OpenSSL::PKey::EC::Group.new(@curve)
        team_key_point = OpenSSL::PKey::EC::Point.new(group_for_team_key, decoded_team_key)

        shared_key = ec.dh_compute_key(team_key_point)

        if @curve == 'prime256v1'
          # Perform KDF
          encoded_ephemeral_key = @p256.encode(decompressed_key: @ephemeral_public_key.to_bn(:uncompressed).to_s(16)).to_der
          hash_input = shared_key + [00, 00, 00, 01].pack('C*') + encoded_ephemeral_key
          hash = OpenSSL::Digest::SHA256.new()
          digest = hash.digest(hash_input)
          return digest
        end  

        shared_key
      end

      private def format(datatype, iv, team_key, encrypted_data)
        "ev:#{@ev_version}#{
          datatype != 'string' ? ':' + datatype : ''
        }:#{base_64_remove_padding(iv)}:#{base_64_remove_padding(
          team_key
        )}:#{base_64_remove_padding(encrypted_data)}:$"
      end

      private def base_64_remove_padding(str)
        str.gsub(/={1,2}$/, '');
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
