require_relative '../errors/errors'
require_relative 'curves/p256'
require_relative 'curves/koblitz'
require_relative '../version'
require 'openssl'
require 'base64'
require 'json'
require 'securerandom'
require 'time'

module Evervault
  module Crypto
    class Client
      attr_reader :config

      def initialize(request_handler:, config: ::Evervault::Config.new)
        @config = config
        @p256 = Evervault::Crypto::Curves::P256.new
        @koblitz = Evervault::Crypto::Curves::Koblitz.new
        @ev_version = base_64_remove_padding(Base64.strict_encode64(EV_VERSION[config.curve]))
        response = request_handler.get('cages/key')
        key = config.curve == 'secp256k1' ? 'ecdhKey' : 'ecdhP256Key'
        @team_key = response[key]
      end

      def encrypt(data, role = nil)
        if data.nil? || (data.instance_of?(String) && data.empty?)
          raise Evervault::Errors::EvervaultError.new(
            'Data is required for encryption'
          )
        end

        unless encryptable_data?(data) || data.instance_of?(Hash) || data.instance_of?(Array)
          raise Evervault::Errors::EvervaultError.new(
            "Encryption is not supported for #{data.class}"
          )
        end

        traverse_and_encrypt(data, role)
      end

      private def encrypt_string(data_to_encrypt, role)
        cipher = OpenSSL::Cipher.new('aes-256-gcm').encrypt

        shared_key = generate_shared_key
        cipher.key = shared_key

        iv = cipher.random_iv
        cipher.iv = iv

        cipher.auth_data = Base64.strict_decode64(@team_key)

        metadata = generate_metadata(role)
        metadata_offset = [metadata.length].pack('v') # 'v' specifies 16-bit unsigned little-endian
        payload = metadata_offset + metadata + data_to_encrypt.to_s

        encrypted_data = cipher.update(payload.to_s) + cipher.final + cipher.auth_tag

        ephemeral_key_compressed_string = @ephemeral_public_key.to_octet_string(:compressed)

        format(header_type(data_to_encrypt), Base64.strict_encode64(iv),
               Base64.strict_encode64(ephemeral_key_compressed_string), Base64.strict_encode64(encrypted_data))
      end

      def generate_metadata(role)
        buffer = []

        # Binary representation of a fixed map with 2 or 3 items, followed by the key-value pairs
        buffer.push(0x80 | (role.nil? ? 2 : 3))

        if role
          # Binary representation for a fixed string of length 2, followed by `dr` (for "data role")
          buffer.push(0xA2)
          buffer.push(*'dr'.bytes)
          # Binary representation for a fixed string of role name length, followed by the role name itself
          buffer.push(0xA0 | role.length)
          buffer.push(*role.bytes)
        end

        # Binary representation for a fixed string of length 2, followed by `eo` (for "encryption origin")
        buffer.push(0xA2)
        buffer.push(*'eo'.bytes)
        # Binary representation for the integer 8 (Ruby SDK)
        buffer.push(8)

        # Binary representation for a fixed string of length 2, followed by `et` (for "encryption timestamp")
        buffer.push(0xA2)
        buffer.push(*'et'.bytes)
        # Binary representation for a 4-byte unsigned integer (uint 32), followed by the epoch time (big-endian)
        buffer.push(0xCE)
        buffer.push(*[Time.now.to_i].pack('I!>').bytes)

        buffer.pack('C*')
      end

      private def traverse_and_encrypt(data, role)
        if encryptable_data?(data)
          return encrypt_string(data, role)
        elsif data.instance_of?(Hash)
          encrypted_data = {}
          data.each { |key, value| encrypted_data[key] = traverse_and_encrypt(value, role) }
          return encrypted_data
        elsif data.instance_of?(Array)
          encrypted_data = data.map { |value| traverse_and_encrypt(value, role) }
          return encrypted_data
        else
          raise Evervault::Errors::EvervaultError.new(
            "Encryption is not supported for #{data.class}"
          )
        end

        data
      end

      private def encryptable_data?(data)
        data.instance_of?(String) || [true, false].include?(data) ||
        data.instance_of?(Integer) || data.instance_of?(Float)
      end

      private def generate_shared_key
        ec = OpenSSL::PKey::EC.generate(config.curve)
        @ephemeral_public_key = ec.public_key

        decoded_team_key = OpenSSL::BN.new(Base64.strict_decode64(@team_key), 2)
        group_for_team_key = OpenSSL::PKey::EC::Group.new(config.curve)
        team_key_point = OpenSSL::PKey::EC::Point.new(group_for_team_key, decoded_team_key)

        shared_key = ec.dh_compute_key(team_key_point)

        # Perform KDF
        encoded_ephemeral_key = if config.curve == 'prime256v1'
                                  @p256.encode(decompressed_key: @ephemeral_public_key.to_bn(:uncompressed).to_s(16)).to_der
                                else
                                  @koblitz.encode(decompressed_key: @ephemeral_public_key.to_bn(:uncompressed).to_s(16)).to_der
                                end
        hash_input = shared_key + [0o0, 0o0, 0o0, 0o1].pack('C*') + encoded_ephemeral_key
        hash = OpenSSL::Digest.new('SHA256')
        hash.digest(hash_input)
      end

      private def format(datatype, iv, team_key, encrypted_data)
        "ev:#{@ev_version}#{
          datatype != 'string' ? ':' + datatype : ''
        }:#{base_64_remove_padding(iv)}:#{base_64_remove_padding(
          team_key
        )}:#{base_64_remove_padding(encrypted_data)}:$"
      end

      private def base_64_remove_padding(str)
        str.gsub(/={1,2}$/, '')
      end

      private def header_type(data)
        if data.instance_of?(Array)
          'Array'
        elsif [true, false].include?(data)
          'boolean'
        elsif data.instance_of?(Hash)
          'object'
        elsif data.instance_of?(Float) || data.instance_of?(Integer)
          'number'
        elsif data.instance_of?(String)
          'string'
        end
      end
    end
  end
end
