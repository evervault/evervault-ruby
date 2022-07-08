require_relative "spec_helper"
require "webmock"

RSpec.describe Evervault do
  describe "test_encoding_of_p256_public_key" do
    it "encodes key correctly" do
      p256 = Evervault::Crypto::Curves::P256.new()
      der_encoded = p256.encode(
        decompressed_key: "04b7556ac070c439ba914e6e2f3ba2e582304dc548524ffc8414abc07ab5a843ecb1f1d71d3a620e6a7c08b895a72d62e2250d248a31da2a5d59ba6ecd636726c4"
      ).to_der

      expected_der = "MIIBSzCCAQMGByqGSM49AgEwgfcCAQEwLAYHKoZIzj0BAQIhAP////8AAAABAAAAAAAAAAAAAAAA////////////////MFsEIP////8AAAABAAAAAAAAAAAAAAAA///////////////8BCBaxjXYqjqT57PrvVV2mIa8ZR0GsMxTsPY7zjw+J9JgSwMVAMSdNgiG5wSTamZ44ROdJreBn36QBEEEaxfR8uEsQkf4vOblY6RA8ncDfYEt6zOg9KE5RdiYwpZP40Li/hp/m47n60p8D54WK84zV2sxXs7LtkBoN79R9QIhAP////8AAAAA//////////+85vqtpxeehPO5ysL8YyVRAgEBA0IABLdVasBwxDm6kU5uLzui5YIwTcVIUk/8hBSrwHq1qEPssfHXHTpiDmp8CLiVpy1i4iUNJIox2ipdWbpuzWNnJsQ="
      
      expect(Base64.strict_encode64(der_encoded)).to eq(expected_der)
    end
  end
end
