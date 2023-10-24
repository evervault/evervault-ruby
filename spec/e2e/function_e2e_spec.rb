require 'faraday'
require 'json'
require_relative "spec_helper"

payload = {
  string: 'hello',
  integer: 1,
  float: 1.5,
  true: true,
  false: false,
  array: ['hello', 1, 1.5, true, false],
  obj: {
    hello: 'world',
  },
};

expected_response = {
  "string"=> 'string',
  "integer"=> 'number',
  "float"=> 'number',
  "true"=> 'boolean',
  "false"=> 'boolean',
  "array"=> {
    "0" => 'string',
    "1" => 'number',
    "2" => 'number',
    "3" => 'boolean',
    "4" => 'boolean',
  },
  "obj"=> { "hello"=> 'string' },
};

RSpec.describe Evervault do
    describe "E2E Function Tests" do
      app_uuid = ENV["EVERVAULT_APP_UUID"]
      api_key = ENV["EVERVAULT_API_KEY"]
      function_name = ENV["EVERVAULT_FUNCTION_NAME"]
      initialisation_error_function_name = ENV["EVERVAULT_INITIALIZATION_ERROR_FUNCTION_NAME"]
      Evervault.app_id = app_uuid
      Evervault.api_key = api_key
      
      it "should run a function" do
        encryptResult = Evervault.encrypt(payload)
        function_run_result = Evervault.run(function_name, payload)
        expect(function_run_result["result"]).to eq(expected_response)
      end
      
      it "should run a function and catch user errors" do
        expect { Evervault.run(function_name, { "shouldError" => true }) }.to raise_error(Evervault::Errors::FunctionRuntimeError)
      end
      
      it "should run a function and catch initialization errors" do
        expect { Evervault.run(initialisation_error_function_name, { }) }.to raise_error(Evervault::Errors::FunctionRuntimeError)
      end

      it "should create a run token" do
        encrypt_result = Evervault.encrypt(payload)

        run_token = Evervault.create_run_token(function_name, encrypt_result)

        function_run_result = run_function_with_token(run_token["token"], function_name, encrypt_result)
        expect(function_run_result["result"]).to eq(expected_response)
      end
    end

    private def run_function_with_token(token, function_name, payload)
        url = "https://api.evervault.com"
        conn = Faraday.new
        res = conn.post do |req|
            req.url "#{url}/functions/#{function_name}/runs"
            req.headers['Content-Type'] = 'application/json'
            req.headers['Authorization'] = "RunToken #{token}"
            req.body = { "payload": payload }.to_json
        end
        return JSON.parse res.body
    end
end