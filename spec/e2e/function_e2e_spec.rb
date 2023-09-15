require 'faraday'
require 'json'
require_relative "spec_helper"

RSpec.describe Evervault do
    describe "E2E Function Tests" do
      app_uuid = ENV["EVERVAULT_APP_UUID"]
      api_key = ENV["EVERVAULT_API_KEY"]
      function_name = ENV["EVERVAULT_FUNCTION_NAME"]
      Evervault.app_id = app_uuid
      Evervault.api_key = api_key
      
      it "should run a function" do
        payload = {"name" => "John Doe", "age" => 42, "isAlive" => true}
        encryptResult = Evervault.encrypt(payload)
        function_run_result = Evervault.run(function_name, payload, {"async" => false})
        expect(function_run_result["result"]["decrypted"]).to eq(payload)
      end

      it "should run a function async" do
        payload = {"name" => "John Doe", "age" => 42, "isAlive" => true}
        options = {async: true}

        encrypt_result = Evervault.encrypt(payload)

        function_run_result = Evervault.run(function_name, encrypt_result, options)
        expect(function_run_result).to eq(nil)
      end

      it "should create a run token" do
        payload = {"name" => "John Doe", "age" => 42, "isAlive" => true}
        encrypt_result = Evervault.encrypt(payload)

        run_token = Evervault.create_run_token(function_name, encrypt_result)

        function_run_result = run_function_with_token(run_token["token"], function_name, encrypt_result)
        expect(function_run_result["result"]["decrypted"]).to eq(payload)
      end
    end

    private def run_function_with_token(token, function_name, payload)
        url = "https://run.evervault.com"
        conn = Faraday.new
        res = conn.post do |req|
            req.url "#{url}/#{function_name}"
            req.headers['Content-Type'] = 'application/json'
            req.headers['Authorization'] = "Bearer #{token}"
            req.body = payload.to_json
        end
        return JSON.parse res.body
    end
end