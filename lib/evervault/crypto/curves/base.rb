require "openssl"

module Evervault
  module Crypto
    class CurveBase
      def initialize(curve_name:, curve_values:)
        @asn1Encoder = buildEncoder(curve_values: curve_values)
      end

      def encode(decompressed_key:)
        @asn1Encoder.call(decompressed_key)
      end

      private def buildEncoder(curve_values:)
        a = OpenSSL::ASN1::OctetString.new([curve_values::A].pack('H*'))
        b = OpenSSL::ASN1::OctetString.new([curve_values::B].pack('H*'))
        if !curve_values::SEED.nil?
          seed = OpenSSL::ASN1::BitString.new([curve_values::SEED].pack('H*'))
          curve = OpenSSL::ASN1::Sequence.new([a, b, seed])
        else
          curve = OpenSSL::ASN1::Sequence.new([a, b])
        end

        field_type = OpenSSL::ASN1::ObjectId.new("1.2.840.10045.1.1")
        parameters = OpenSSL::ASN1::Integer.new(curve_values::P.to_i(16))
        field_id = OpenSSL::ASN1::Sequence.new([field_type, parameters])

        version = OpenSSL::ASN1::Integer.new(1)
        base = OpenSSL::ASN1::OctetString.new([curve_values::GENERATOR].pack('H*'))
        order = OpenSSL::ASN1::Integer.new(curve_values::N.to_i(16))
        cofactor = OpenSSL::ASN1::Integer.new(curve_values::H.to_i(16))
        ec_parameters = OpenSSL::ASN1::Sequence.new([version, field_id, curve, base, order, cofactor])

        algorithm = OpenSSL::ASN1::ObjectId.new("1.2.840.10045.2.1")
        algorithm_identifier = OpenSSL::ASN1::Sequence.new([algorithm, ec_parameters])

        return lambda { |public_key|
                 OpenSSL::ASN1::Sequence.new([algorithm_identifier,
                                              OpenSSL::ASN1::BitString.new([public_key].pack('H*'))])
               }
      end
    end
  end
end
