require_relative "spec_helper"

RSpec.describe Evervault do
  describe "E2E Encrypt Tests" do
    app_uuid = ENV["EVERVAULT_APP_UUID"]
    api_key = ENV["EVERVAULT_API_KEY"]

    describe "secp256k1" do
      client = Evervault::Client.new(app_uuid: app_uuid, api_key: api_key, curve: "secp256k1")

      it "should encrypt a string" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should decrypt a string with a permitting role" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a string with a denying role" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt an integer" do
        payload = 1
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt an integer with a permitting role" do
        payload = 1
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting an integer with a denying role" do
        payload = 1
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a float" do
        payload = 1.0
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a float with a permitting role" do
        payload = 1.0
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a float with a denying role" do
        payload = 1.0
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a true bool" do
        payload = true
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a true bool with a permitting role" do
        payload = true
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a true bool with a denying role" do
        payload = true
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a false bool" do
        payload = false
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a false bool with a permitting role" do
        payload = false
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a false bool with a denying role" do
        payload = true
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a hash" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a hash with a permitting role" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a hash with a denying role" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end

    describe "prime256v1" do
      client = Evervault::Client.new(app_uuid: app_uuid, api_key: api_key, curve: "prime256v1")

      it "should encrypt a string" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should decrypt a string with a permitting role" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a string with a denying role" do
        payload = "hello world"
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt an integer" do
        payload = 1
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt an integer with a permitting role" do
        payload = 1
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting an integer with a denying role" do
        payload = 1
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a float" do
        payload = 1.0
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a float with a permitting role" do
        payload = 1.0
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a float with a denying role" do
        payload = 1.0
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a true bool" do
        payload = true
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

    it "should decrypt a false bool with a permitting role" do
      payload = false
      encryptResult = Evervault.encrypt(payload, "permit-all")
      decryptResult = Evervault.decrypt(encryptResult)
      expect(decryptResult).to eq(payload)
    end
    
    it "should error decrypting a false bool with a denying role" do
      payload = false
      encryptResult = Evervault.encrypt(payload, "deny-all")
      expect{ Evervault.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
    end

      it "should encrypt a false bool" do
        payload = false
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a false bool with a permitting role" do
        payload = false
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a false bool with a denying role" do
        payload = true
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it "should encrypt a hash" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, nil)
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end

      it "should decrypt a hash with a permitting role" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, "permit-all")
        decryptResult = client.decrypt(encryptResult)
        expect(decryptResult).to eq(payload)
      end
      
      it "should error decrypting a hash with a denying role" do
        payload = {"hello" => "world"}
        encryptResult = client.encrypt(payload, "deny-all")
        expect{ client.decrypt(encryptResult) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end
  end
end