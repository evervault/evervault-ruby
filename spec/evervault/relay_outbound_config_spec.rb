require 'webmock'
require 'json'

RSpec.describe Evervault do
  let(:config) { Evervault::Config.new(app_id: 'app_test', api_key: 'testing') }
  let(:request) { Evervault::Http::Request.new(config: config) }

  after :each do
    Evervault::Http::RelayOutboundConfig.disable_polling
    Evervault::Http::RelayOutboundConfig.clear_cache
  end

  describe 'RelayOutboundConfig' do
    describe 'initialize' do
      it 'should retrieve the relay outbound config if not already cached' do
        mock_api_interaction(single_outbound_destination)
        relay_outbound_config = create_relay_outbound_config
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
      end

      it 'should start polling if not already polling' do
        mock_api_interaction(single_outbound_destination, 0.1)
        relay_outbound_config = create_relay_outbound_config
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
        mock_api_interaction(double_outbound_destinations, 0.1)

        sleep 1

        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com',
                                                                     'test-two.destinations.com'])
      end

      it 'should update the poll interval based on the server response' do
        mock_api_interaction(single_outbound_destination, 0.2)
        relay_outbound_config = create_relay_outbound_config
        mock_api_interaction(single_outbound_destination, 0.1)

        sleep 1

        mock_api_interaction(double_outbound_destinations, 0.1)

        sleep 1

        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com',
                                                                     'test-two.destinations.com'])
      end

      it 'should not update the poll interval if not specified by the server' do
        mock_api_interaction(single_outbound_destination, 1)
        relay_outbound_config = create_relay_outbound_config
        mock_api_interaction_without_poll_interval(double_outbound_destinations)

        sleep 1.9

        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com',
                                                                     'test-two.destinations.com'])
      end

      it 'should silently ignore exceptions thrown when polling' do
        mock_api_interaction(single_outbound_destination, 0.1)
        relay_outbound_config = create_relay_outbound_config
        mock_failed_api_interaction

        sleep 1

        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
      end
    end

    describe 'get_destination_domains' do
      it 'returns the cached destination domains' do
        mock_api_interaction(single_outbound_destination)
        relay_outbound_config = create_relay_outbound_config
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
      end
    end

    describe 'disable_polling' do
      it 'stops the timer' do
        mock_api_interaction(single_outbound_destination, 0.1)
        relay_outbound_config = create_relay_outbound_config
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
        Evervault::Http::RelayOutboundConfig.disable_polling

        sleep 0.5

        mock_api_interaction(double_outbound_destinations)
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
      end
    end

    describe 'clear_cache' do
      it 'clears the cache' do
        mock_api_interaction(single_outbound_destination)
        relay_outbound_config = create_relay_outbound_config
        expect(relay_outbound_config.get_destination_domains).to eq(['test-one.destinations.com'])
        Evervault::Http::RelayOutboundConfig.clear_cache
        expect(relay_outbound_config.get_destination_domains).to eq(nil)
      end
    end
  end

  private def create_relay_outbound_config
    Evervault::Http::RelayOutboundConfig.new(
      base_url: 'https://api.evervault.com/',
      request: request
    )
  end

  private def mock_api_interaction(response_body, poll_interval = '5')
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
        body: response_body.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-Poll-Interval' => "#{poll_interval}"
        }
      )
  end

  private def mock_api_interaction_without_poll_interval(response_body)
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
        body: response_body.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )
  end

  private def mock_failed_api_interaction
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
        status: 400,
        headers: {
          'Content-Type' => 'application/json'
        }
      )
  end

  private def single_outbound_destination
    {
      'appUuid' => 'app_33b88ca7da01',
      'teamUuid' => '2ef8d35ce661',
      'strictMode' => true,
      'outboundDestinations' => {
        'test-one.destinations.com' => {
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
          'destinationDomain' => 'test-one.destinations.com'
        }
      }
    }
  end

  private def double_outbound_destinations
    {
      'appUuid' => 'app_33b88ca7da01',
      'teamUuid' => '2ef8d35ce661',
      'strictMode' => true,
      'outboundDestinations' => {
        'test-one.destinations.com' => {
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
          'destinationDomain' => 'test-one.destinations.com'
        },
        'test-two.destinations.com' => {
          'id' => 20,
          'appUuid' => 'app_33b88ca7da01',
          'createdAt' => '2022-07-20T16: 02: 36.601Z',
          'updatedAt' => '2022-10-05T12: 40: 44.511Z',
          'deletedAt' => nil,
          'routeSpecificFieldsToEncrypt' => [],
          'deterministicFieldsToEncrypt' => [],
          'encryptEmptyStrings' => true,
          'curve' => 'secp256k1',
          'uuid' => 'outbound_destination_e7f791332c51',
          'destinationDomain' => 'test-two.destinations.com'
        }
      }
    }
  end
end
