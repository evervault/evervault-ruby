# frozen_string_literal: true

require_relative 'spec_helper'
require 'faraday'
require 'json'

payload = {
  string: 'hello',
  integer: 1,
  float: 1.5,
  true: true,
  false: false,
  array: ['hello', 1, 1.5, true, false],
  obj: {
    hello: 'world'
  }
}

expected_response = {
  'string' => 'string',
  'integer' => 'number',
  'float' => 'number',
  'true' => 'boolean',
  'false' => 'boolean',
  'array' => {
    '0' => 'string',
    '1' => 'number',
    '2' => 'number',
    '3' => 'boolean',
    '4' => 'boolean'
  },
  'obj' => { 'hello' => 'string' }
}

RSpec.describe 'Running functions' do
  let(:function_name) { ENV['EVERVAULT_FUNCTION_NAME'] }
  let(:initialization_error_function_name) { ENV['EVERVAULT_INITIALIZATION_ERROR_FUNCTION_NAME'] }

  before :each do
    Evervault.app_id = ENV['EVERVAULT_APP_UUID']
    Evervault.api_key = ENV['EVERVAULT_API_KEY']
  end

  it 'should run a function' do
    function_run_result = Evervault.run(function_name, payload)
    expect(function_run_result['result']).to eq(expected_response)
  end

  it 'should run a function and catch user errors' do
    expect do
      Evervault.run(function_name, { shouldError: true })
    end.to raise_error(Evervault::Errors::FunctionRuntimeError)
  end

  it 'should run a function and catch initialization errors' do
    expect do
      Evervault.run(initialization_error_function_name, {})
    end.to raise_error(Evervault::Errors::FunctionRuntimeError)
  end

  it 'should create a run token' do
    encrypt_result = Evervault.encrypt(payload)

    run_token = Evervault.create_run_token(function_name, encrypt_result)

    function_run_result = run_function_with_token(run_token['token'], function_name, encrypt_result)
    expect(function_run_result['result']).to eq(expected_response)
  end

  private

  def run_function_with_token(token, function_name, payload)
    url = 'https://api.evervault.com'
    conn = Faraday.new
    res = conn.post do |req|
      req.url "#{url}/functions/#{function_name}/runs"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "RunToken #{token}"
      req.body = { "payload": payload }.to_json
    end
    JSON.parse res.body
  end
end
