require_relative "spec_helper"

RSpec.describe Evervault do
  describe "E2E Function Tests" do
    app_uuid = ENV["EVERVAULT_APP_UUID"]
    api_key = ENV["EVERVAULT_API_KEY"]
    synthetic_endpoint_url = ENV["EVERVAULT_SYNTHETIC_ENDPOINT_URL"]
    Evervault.app_id = app_uuid
    Evervault.api_key = api_key
      
    it "should enable outbound relay" do
      Evervault.enable_outbound_relay()

      payload = {"string" => "some_string", "number" => 42, "boolean" => true}
      encryptResult = Evervault.encrypt(payload)

      url = synthetic_endpoint_url
      conn = Faraday.new
      res = conn.post do |req|
        req.url "#{url}/production?uuid=ruby-sdk-run&mode=outbound"
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json
      end

      body = JSON.parse res.body

      expect(body["request"]["string"]).to eq(false)
      expect(body["request"]["number"]).to eq(false)
      expect(body["request"]["boolean"]).to eq(false)
    end
  end
end
