# frozen_string_literal: true

RSpec.describe Evervault::Crypto::Client do
  let(:config) { Evervault::Config.new(app_id: 'app_test', api_key: 'testing') }
  let(:request) { Evervault::Http::Request.new(config: config) }
  let(:intercept) { Evervault::Http::RequestIntercept.new(request: request, config: config) }
  let(:request_handler) { Evervault::Http::RequestHandler.new(request: request, config: config, cert: intercept) }
  let(:client) { Evervault::Crypto::Client.new(request_handler: request_handler, config: config) }

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
