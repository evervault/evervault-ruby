# frozen_string_literal: true

require_relative 'spec_helper'

curves = %w[secp256k1 prime256v1].freeze

RSpec.describe 'Encryption' do
  curves.each do |curve|
    context "with #{curve} curve" do
      let(:client) do
        Evervault::Client.new(
          app_uuid: ENV['EVERVAULT_APP_UUID'],
          api_key: ENV['EVERVAULT_API_KEY'],
          curve: curve
        )
      end

      it 'should encrypt a string' do
        payload = 'hello world'
        encrypted = client.encrypt(payload)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt a string with a permitting role' do
        payload = 'hello world'
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting a string with a denying role' do
        payload = 'hello world'
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt an integer' do
        payload = 1
        encrypted = client.encrypt(payload)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt an integer with a permitting role' do
        payload = 1
        encrypted = client.encrypt(payload, "permit-all")
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting an integer with a denying role' do
        payload = 1
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt a float' do
        payload = 1.0
        encrypted = client.encrypt(payload)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt a float with a permitting role' do
        payload = 1.0
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting a float with a denying role' do
        payload = 1.0
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt a true bool' do
        payload = true
        encrypted = client.encrypt(payload)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt a true bool with a permitting role' do
        payload = true
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting a true bool with a denying role' do
        payload = true
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt a false bool' do
        payload = false
        encrypted = client.encrypt(payload)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt a false bool with a permitting role' do
        payload = false
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting a false bool with a denying role' do
        payload = false
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt a hash' do
        payload = { 'hello' => 'world' }
        encrypted = client.encrypt(payload, nil)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt a hash with a permitting role' do
        payload = { 'hello' => 'world' }
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting a hash with a denying role' do
        payload = { 'hello' => 'world' }
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end

      it 'should encrypt an array' do
        payload = ['Testing', 123, false]
        encrypted = client.encrypt(payload, nil)
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should decrypt an array with a permitting role' do
        payload = ['Testing', 123, false]
        encrypted = client.encrypt(payload, 'permit-all')
        decrypted = client.decrypt(encrypted)
        expect(decrypted).to eq(payload)
      end

      it 'should error decrypting an array with a denying role' do
        payload = ['Testing', 123, false]
        encrypted = client.encrypt(payload, 'deny-all')
        expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end
  end
end
