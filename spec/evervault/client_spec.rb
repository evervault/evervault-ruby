# frozen_string_literal: true

RSpec.describe Evervault::Client do
  let(:client) { Evervault::Client.new(app_uuid: 'app_test', api_key: 'testing') }

  before :each do
    mock_valid_cert
    mock_cages_keys
  end

  describe '#encrypt' do
    it 'delegates to the crypto client' do
      crypto = instance_double(Evervault::Crypto::Client)
      allow(client).to receive(:crypto_client).and_return(crypto)
      expect(crypto).to receive(:encrypt).with("Data", "role")
      client.encrypt("Data", "role")
    end
  end

  describe '#decrypt' do
    it 'calls the decrypt API' do
      stub = stub_request(:post, 'https://api.evervault.com/decrypt').with(
        body: { "data": 'Encrypted' }
      ).to_return_json(body: { "data": 'Decrypted' })

      result = client.decrypt('Encrypted')
      expect(stub).to have_been_requested
      expect(result).to eq('Decrypted')
    end

    context 'when passed an invalid type' do
      it 'raises an error' do
        expect { client.decrypt(100) }.to raise_error(Evervault::Errors::EvervaultError, /invalid type/)
      end
    end
  end
end
