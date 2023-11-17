# frozen_string_literal: true

RSpec.describe Evervault::Crypto::Client do
  let(:request) do
    Evervault::Http::Request.new(
      timeout: 30,
      app_uuid: 'app_test',
      api_key: 'testing'
    )
  end

  let(:intercept) do
    Evervault::Http::RequestIntercept.new(
      request: request,
      ca_host: 'https://ca.evervault.com',
      api_key: 'testing',
      base_url: 'https://api.evervault.com/',
      relay_url: 'https://relay.evervault.com:8443'
    )
  end

  let(:request_handler) do
    Evervault::Http::RequestHandler.new(
      request: request,
      base_url: 'https://api.evervault.com/',
      cert: intercept
    )
  end

  let(:curve) { 'secp256k1' }
  let(:client) { Evervault::Crypto::Client.new(request_handler: request_handler, curve: curve) }

  describe '#encrypt' do
    before do
      mock_valid_cert
      mock_cages_keys
    end

    it 'encrypts strings and does not include the type in the cipher text' do
      result = client.encrypt('test')
      expect(result).to start_with('ev:')
      expect(result).to_not include(':string:')
    end

    it 'encrypts numbers and includes number in the cipher text' do
      result = client.encrypt(123)
      expect(result).to start_with('ev:')
      expect(result).to include(':number:')
    end

    it 'encrypts booleans and includes boolean in the cipher text' do
      result = client.encrypt(true)
      expect(result).to start_with('ev:')
      expect(result).to include(':boolean:')
    end

    it 'encrypts arrays' do
      data = ['test', 123, true]
      result = client.encrypt(data)
      expect(result).to be_an(Array)
      expect(result[0]).to start_with('ev:')
      expect(result[1]).to start_with('ev:')
      expect(result[1]).to include(':number:')
      expect(result[2]).to start_with('ev:')
      expect(result[2]).to include(':boolean:')
    end

    it 'encrypts hashes' do
      data = {
        age: 20,
        name: 'test',
        ratings: [1, 2, 3],
        nested: {
          bool: true
        }
      }

      result = client.encrypt(data)
      expect(result).to be_a(Hash)
      expect(result[:age]).to start_with('ev:')
      expect(result[:age]).to include(':number:')
      expect(result[:name]).to start_with('ev:')
      expect(result[:ratings]).to be_an(Array)

      result[:ratings].each do |rating|
        expect(rating).to start_with('ev:')
        expect(rating).to include(':number:')
      end

      expect(result[:nested]).to be_a(Hash)
      expect(result[:nested][:bool]).to start_with('ev:')
      expect(result[:nested][:bool]).to include(':boolean:')
    end

    context 'when passed a symbol' do
      it 'raises an error' do
        expect { client.encrypt(:test) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end

    context 'when passed an array containing invalid data' do
      it 'raises an error' do
        data = ['Test', :test]
        expect { client.encrypt(data) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end

    context 'when passed a hash containing invalid data' do
      it 'raises an error' do
        data = { name: 'Test', status: :invalid }
        expect { client.encrypt(data) }.to raise_error(Evervault::Errors::EvervaultError)
      end
    end
  end
end
