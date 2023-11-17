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

      context 'when given a string' do
        let(:payload) { 'hello world' }

        it 'should encrypt the value' do
          encrypted = client.encrypt(payload)
          expect(encrypted).to be_encrypted
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should decrypt with a permitting role' do
          encrypted = client.encrypt(payload, 'permit-all')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should error decrypting with a denying role' do
          encrypted = client.encrypt(payload, 'deny-all')
          expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
        end
      end

      context 'when given an integer' do
        let(:payload) { 123 }

        it 'should encrypt' do
          encrypted = client.encrypt(payload)
          expect(encrypted).to be_encrypted('number')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should decrypt with a permitting role' do
          encrypted = client.encrypt(payload, 'permit-all')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should error decrypting with a denying role' do
          encrypted = client.encrypt(payload, 'deny-all')
          expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
        end
      end

      context 'when given a float' do
        let(:payload) { 1.0 }

        it 'should encrypt' do
          encrypted = client.encrypt(payload)
          expect(encrypted).to be_encrypted('number')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should decrypt with a permitting role' do
          encrypted = client.encrypt(payload, 'permit-all')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should error decrypting with a denying role' do
          encrypted = client.encrypt(payload, 'deny-all')
          expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
        end
      end

      context 'when given a boolean' do
        it 'should encrypt a true bool' do
          payload = true
          encrypted = client.encrypt(payload)
          expect(encrypted).to be_encrypted('boolean')
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
          expect(encrypted).to be_encrypted('boolean')
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
      end

      context 'when given a hash' do
        let(:payload) do
          {
            'name' => 'John Doe',
            'age' => 30,
            'rating' => 4.5,
            'admin' => false,
            'permissions' => %w[read write],
            'address' => {
              'street' => '123 Fake Street',
              'city' => 'Fake City',
              'country' => 'Fake Country'
            }
          }
        end

        it 'should encrypt all of the values' do
          encrypted = client.encrypt(payload, nil)
          expect(encrypted['name']).to be_encrypted
          expect(encrypted['age']).to be_encrypted('number')
          expect(encrypted['rating']).to be_encrypted('number')
          expect(encrypted['admin']).to be_encrypted('boolean')
          expect(encrypted['permissions'][0]).to be_encrypted
          expect(encrypted['address']['street']).to be_encrypted
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should decrypt all of the values with a permitting role' do
          encrypted = client.encrypt(payload, 'permit-all')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should error decrypting with a denying role' do
          encrypted = client.encrypt(payload, 'deny-all')
          expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
        end
      end

      context 'when given an array' do
        let(:payload) { ['Testing', 123, false] }

        it 'should encrypt all values' do
          encrypted = client.encrypt(payload, nil)
          expect(encrypted[0]).to be_encrypted
          expect(encrypted[1]).to be_encrypted('number')
          expect(encrypted[2]).to be_encrypted('boolean')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should decrypt with a permitting role' do
          encrypted = client.encrypt(payload, 'permit-all')
          decrypted = client.decrypt(encrypted)
          expect(decrypted).to eq(payload)
        end

        it 'should error decrypting with a denying role' do
          encrypted = client.encrypt(payload, 'deny-all')
          expect { client.decrypt(encrypted) }.to raise_error(Evervault::Errors::EvervaultError)
        end
      end
    end
  end
end
