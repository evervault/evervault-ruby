# frozen_string_literal: true

RSpec.describe Evervault do
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
  let(:crypto_client) do
    Evervault::Crypto::Client.new(request_handler: request_handler, curve: 'secp256k1')
  end

  before :each do
    mock_valid_cert
    mock_cages_keys
    Evervault.app_id = 'app_test'
    Evervault.api_key = 'testing'
    allow(Time).to receive(:now).and_return(Time.parse('2022-06-06'))
  end

  it 'has a version number' do
    expect(Evervault::VERSION).not_to be nil
  end

  describe '.encrypt' do
    it 'delegates to the evervault client' do
      client = double('client')
      allow(Evervault).to receive(:client).and_return(client)
      expect(client).to receive(:encrypt).with('test')
      Evervault.encrypt('test')
    end
  end

  describe '.decrypt' do
    it 'delegates to the evervault client' do
      client = double('client')
      allow(Evervault).to receive(:client).and_return(client)
      expect(client).to receive(:decrypt).with('encrypted')
      Evervault.decrypt('encrypted')
    end
  end

  describe '.run' do
    it 'delegates to the evervault client' do
      client = double('client')
      allow(Evervault).to receive(:client).and_return(client)
      expect(client).to receive(:run).with('test', { foo: 'bar' })
      Evervault.run('test', { foo: 'bar' })
    end
  end

  describe 'create_client_side_decrypt_token' do
    before do
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request_handler)
      stub_request(:post, 'https://api.evervault.com/client-side-tokens').with(
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Basic YXBwX3Rlc3Q6dGVzdGluZw==',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding' => 'gzip, deflate',
          'Content-Type' => 'application/json',
          'User-Agent' => "evervault-ruby/#{Evervault::VERSION}"
        },
        body: {
          payload: 'test',
          expiry: 1_691_596_854_000,
          action: 'api:decrypt'
        }.to_json
      ).to_return({ status: status, body: response.to_json })
    end

    context 'success' do
      let(:response) { { token: 'token1234567890', expiry: 1_691_596_854_000 } }
      let(:status) { 200 }

      it 'makes a post request to the API' do
        Evervault.create_client_side_decrypt_token('test', Time.parse('2023-08-09 16:00:54 +0000'))
        assert_requested(:post, 'https://api.evervault.com/client-side-tokens',
                         body: { action: 'api:decrypt', payload: 'test', expiry: 1_691_596_854_000 }, times: 1)
      end
    end

    context 'failure' do
      let(:response) do
        {
          "status": 400,
          "code": 'invalid-request',
          "title": 'InvalidRequest',
          "detail": 'Bad request!'
        }
      end
      let(:status) { 400 }
      it 'makes a post request to the API and maps the error' do
        expect do
          Evervault.create_client_side_decrypt_token('test',
                                                     Time.parse('2023-08-09 16:00:54 +0000'))
        end.to raise_error(Evervault::Errors::EvervaultError)
        assert_requested(:post, 'https://api.evervault.com/client-side-tokens',
                         body: { action: 'api:decrypt', payload: 'test', expiry: 1_691_596_854_000 }, times: 1)
      end
    end
  end

  describe 'create_run_token' do
    before do
      allow(Evervault::Http::RequestHandler).to receive(:new).and_return(request_handler)
      stub_request(:post, 'https://api.evervault.com/v2/functions/testing-function/run-token').with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding' => 'gzip, deflate',
          'Api-Key' => 'testing',
          'Content-Type' => 'application/json',
          'User-Agent' => "evervault-ruby/#{Evervault::VERSION}"
        },
        body: {
          name: 'testing'
        }.to_json
      ).to_return({ status: status, body: response.to_json })
    end

    context 'success' do
      let(:response) { 'runtoken123' }
      let(:status) { 200 }

      it 'makes a post request to the API' do
        Evervault.create_run_token('testing-function', { name: 'testing' })
        assert_requested(:post, 'https://api.evervault.com/v2/functions/testing-function/run-token',
                         body: { name: 'testing' }, times: 1)
      end
    end

    context 'failure' do
      let(:response) { { 'Error' => 'Bad request' } }
      let(:status) { 400 }

      it 'makes a post request to the API and maps the error' do
        expect do
          Evervault.create_run_token('testing-function', { name: 'testing' })
        end.to raise_error(Evervault::Errors::EvervaultError)
        assert_requested(:post, 'https://api.evervault.com/v2/functions/testing-function/run-token',
                         body: { name: 'testing' }, times: 1)
      end
    end
  end

  describe 'enable_outbound_relay' do
    after :each do
      Evervault::Http::RelayOutboundConfig.disable_polling
      Evervault::Http::RelayOutboundConfig.clear_cache
      NetHTTPOverride.add_get_decryption_domains_func(nil)
    end

    it 'routes http requests to Relay if Outbound Relay is enabled and domain is set' do
      mock_relay_outbound_api_interaction
      Evervault.enable_outbound_relay
      actual = NetHTTPOverride.should_decrypt('foo.com')
      expect(actual).to eq(true)
    end

    it 'does not route http requests to Relay if Outbound Relay is enabled and domain is not set' do
      mock_relay_outbound_api_interaction
      Evervault.enable_outbound_relay
      actual = NetHTTPOverride.should_decrypt('bar.com')
      expect(actual).to eq(false)
    end

    it 'does not route http requests to Relay if Outbound Relay is disabled' do
      actual = NetHTTPOverride.should_decrypt('foo.com')
      expect(actual).to eq(false)
    end

    it 'does not route http requests to Relay if an empty array is passed as the decryption_domains argument' do
      Evervault.enable_outbound_relay([])
      actual = NetHTTPOverride.should_decrypt('foo.com')
      expect(actual).to eq(false)
    end

    it 'routes http requests to Relay if a decryption domain is set' do
      Evervault.enable_outbound_relay(['foo.com'])
      actual = NetHTTPOverride.should_decrypt('foo.com')
      expect(actual).to eq(true)
    end
  end

  private def mock_relay_outbound_api_interaction
    stub_request(:get, 'https://api.evervault.com/v2/relay-outbound')
      .with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding' => 'gzip, deflate',
          'Api-Key' => 'testing',
          'Content-Type' => 'application/json',
          'User-Agent' => "evervault-ruby/#{Evervault::VERSION}"
        }
      )
      .to_return(
        status: 200,
        body: {
          'appUuid' => 'app_33b88ca7da01',
          'teamUuid' => '2ef8d35ce661',
          'strictMode' => true,
          'outboundDestinations' => {
            'foo.com' => {
              'id' => 144,
              'appUuid' => 'app_33b88ca7da01',
              'createdAt' => '2022-10-05T08: 36: 35.681Z',
              'updatedAt' => '2022-10-05T08: 36: 35.681Z',
              'deletedAt' => nil,
              'routeSpecificFieldsToEncrypt' => [],
              'deterministicFieldsToEncrypt' => [],
              'encryptEmptyStrings' => true,
              'curve' => 'secp256k1',
              'uuid' => 'outbound_destination_9733a04135f1',
              'destinationDomain' => 'foo.com'
            }
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-Poll-Interval' => '5'
        }
      )
  end

  private def mock_failed_relay_outbound_api_interaction
    stub_request(:get, 'https://api.evervault.com/v2/relay-outbound')
      .with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Acceptencoding' => 'gzip, deflate',
          'Api-Key' => 'testing',
          'Content-Type' => 'application/json',
          'User-Agent' => "evervault-ruby/#{Evervault::VERSION}"
        }
      )
      .to_return(
        status: 500,
        body: {
          'error' => 'internal_server_error'
        }.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )
  end
end
