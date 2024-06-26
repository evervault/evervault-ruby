# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative '../version'
require_relative '../errors/legacy_error_map'

module Evervault
  module Http
    class Request
      attr_reader :config

      def initialize(config:)
        @config = config
      end

      def execute(method, url, body = nil, basic_auth = false, error_map = Evervault::Errors::LegacyErrorMap)
        resp = faraday(basic_auth).public_send(method, url) do |req, _url|
          req.body = body.nil? || body.empty? ? nil : body.to_json
          req.headers = build_headers(basic_auth)
          req.options.timeout = config.request_timeout
        end

        return resp if resp.status >= 200 && resp.status <= 300

        error_map.raise_errors_on_failure(resp.status, resp.body, resp.headers)
      end

      private

      def faraday(basic_auth = false)
        Faraday.new do |conn|
          conn.request :authorization, :basic, config.app_id, config.api_key if basic_auth
        end
      end

      def build_headers(basic_auth = false)
        headers = {
          "AcceptEncoding": 'gzip, deflate',
          "Accept": 'application/json',
          "Content-Type": 'application/json',
          "User-Agent": "evervault-ruby/#{VERSION}"
        }
        unless basic_auth
          headers = headers.merge({
                                    "Api-Key": config.api_key
                                  })
        end
        headers
      end
    end
  end
end
