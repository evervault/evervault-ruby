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

  describe '#run' do
    let(:status) { 200 }

    before :each do
      stub_request(:post, 'https://api.evervault.com/functions/testing-function/runs').with(
        body: {
          payload: { name: 'testing' }
        }.to_json
      ).to_return({ status: status, body: response.to_json })
    end

    context 'when the function run succeeds' do
      let(:response) do
        {
          "id": 'func_run_b470a269a369',
          "result": { "test": 'data' },
          "status": 'success'
        }
      end

      it 'calls the function run API' do
        payload = { name: 'testing' }
        result = client.run('testing-function', payload)
        assert_requested(:post, 'https://api.evervault.com/functions/testing-function/runs', body: { payload: payload })
        expect(result['id']).to eq(response[:id])
        expect(result['status']).to eq('success')
        expect(result['result']['test']).to eq('data')
      end
    end

    context "when the function run doesn't succeed" do
      let(:response) do
        {
          "error": { "message": 'Uh oh!', "stack": 'Error: Uh oh!...' },
          "id": 'func_run_e4f1d8d83ec0',
          "status": 'failure'
        }
      end

      it 'raises an error' do
        payload = { name: 'testing' }
        expect { client.run('testing-function', payload) }.to raise_error(Evervault::Errors::FunctionRuntimeError)
        assert_requested(:post, 'https://api.evervault.com/functions/testing-function/runs', body: { payload: payload })
      end
    end

    context 'when the API responds with error' do
      let(:response) do
        {
          "status": 400,
          "code": 'invalid-request',
          "title": 'InvalidRequest',
          "detail": 'Bad request!'
        }
      end

      it 'raises an error' do
        payload = { name: 'testing' }
        expect { client.run('testing-function', payload) }.to raise_error(Evervault::Errors::EvervaultError)
        assert_requested(:post, 'https://api.evervault.com/functions/testing-function/runs', body: { payload: payload })
      end
    end
  end

  describe '#create_run_token' do
    let(:status) { 200 }
    let(:response) { 'token' }

    before :each do
      url = 'https://api.evervault.com/v2/functions/testing-function/run-token'
      stub_request(:post, url).to_return({ status: status, body: response.to_json })
    end

    it 'calls the run token API' do
      payload = { name: 'testing' }
      client.create_run_token('testing-function', payload)
      assert_requested(:post, 'https://api.evervault.com/v2/functions/testing-function/run-token', body: payload)
    end

    context 'when the API responds with error' do
      let(:status) { 400 }
      let(:response) do
        {
          "Error": 'Bad request'
        }
      end

      it 'raises an error' do
        payload = { name: 'testing' }
        expect do
          client.create_run_token('testing-function', payload)
        end.to raise_error(Evervault::Errors::EvervaultError)
        assert_requested(:post, 'https://api.evervault.com/v2/functions/testing-function/run-token', body: payload)
      end
    end
  end
end
