# frozen_string_literal: true

module Evervault
  class Config
    attr_accessor :app_id, :api_key, :base_url, :relay_url, :ca_host, :request_timeout, :curve

    def initialize(app_id:, api_key:)
      @app_id = app_id
      @api_key = api_key
      @base_url = 'https://api.evervault.com/'
      @relay_url = 'https://relay.evervault.com:8443'
      @ca_host = 'https://ca.evervault.com'
      @request_timeout = 30
      @curve = 'prime256v1'
    end
  end
end
