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

    context 'when role is passed' do
      it 'passes it to the evervault client' do
        client = double('client')
        allow(Evervault).to receive(:client).and_return(client)
        expect(client).to receive(:encrypt).with('test', 'role')
        Evervault.encrypt('test', 'role')
      end
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

  describe '.create_client_side_decrypt_token' do
    it 'calls client#create_token with the correct arguments' do
      client = double('client')
      allow(Evervault).to receive(:client).and_return(client)
      expect(client).to receive(:create_token).with('api:decrypt', { foo: 'bar' }, nil)
      Evervault.create_client_side_decrypt_token({ foo: 'bar' })
    end

    context 'when expiry is passed' do
      it 'converts the expiration to milliseconds' do
        client = double('client')
        allow(Evervault).to receive(:client).and_return(client)
        expiry = Time.parse('2023-12-25')
        expect(client).to receive(:create_token).with('api:decrypt', { foo: 'bar' }, expiry.to_i * 1000)
        Evervault.create_client_side_decrypt_token({ foo: 'bar' }, expiry)
      end
    end
  end

  describe '.create_run_token' do
    it 'delegates to the evervault client' do
      client = double('client')
      allow(Evervault).to receive(:client).and_return(client)
      expect(client).to receive(:create_run_token).with('test', { foo: 'bar' })
      Evervault.create_run_token('test', { foo: 'bar' })
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
