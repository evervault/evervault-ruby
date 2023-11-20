# frozen_string_literal: true

require_relative 'spec_helper'

# For this test, the sythetic endpoint will respond with true and false values for each field
# depending on whether the field was encrypted or not.

RSpec.describe 'Outbound Relay' do
  before :each do
    Evervault.app_id = ENV['EVERVAULT_APP_UUID']
    Evervault.api_key = ENV['EVERVAULT_API_KEY']
  end

  context 'when outbound is not enabled' do
    it 'should not decrypt any data' do
      payload = Evervault.encrypt({ 'string' => 'some_string', 'number' => 42, 'boolean' => true })
      response = make_request(payload)
      expect(response['request']['string']).to eq(true)
      expect(response['request']['number']).to eq(true)
      expect(response['request']['boolean']).to eq(true)
    end
  end

  context 'when outbound is enabled' do
    before :each do
      Evervault.enable_outbound_relay
    end

    it 'should decrypt any data' do
      payload = Evervault.encrypt({ 'string' => 'some_string', 'number' => 42, 'boolean' => true })
      response = make_request(payload)
      expect(response['request']['string']).to eq(false)
      expect(response['request']['number']).to eq(false)
      expect(response['request']['boolean']).to eq(false)
    end
  end
end

def make_request(payload)
  url = ENV['EVERVAULT_SYNTHETIC_ENDPOINT_URL']

  response = Faraday.new.post do |req|
    req.url "#{url}/production?uuid=ruby-sdk-run&mode=outbound"
    req.headers['Content-Type'] = 'application/json'
    req.body = payload.to_json
  end

  JSON.parse response.body
end
