require "faraday"
require "json"
require_relative "../version"
require_relative "../errors/legacy_error_map"

module Evervault
  module Http
    class Request
      def initialize(timeout:, app_uuid:, api_key:)
        @timeout = timeout
        @app_uuid = app_uuid
        @api_key = api_key
      end

      def execute(method, url, body = nil, basic_auth = false, error_map = Evervault::Errors::LegacyErrorMap)
        resp = faraday(basic_auth).public_send(method, url) do |req, url|
            req.body = body.nil? || body.empty? ? nil : body.to_json
            req.headers = build_headers(basic_auth)
            req.options.timeout = @timeout
        end

        if resp.status >= 200 && resp.status <= 300
          return resp
        end

        error_map.raise_errors_on_failure(resp.status, resp.body, resp.headers)
      end

      private

      def faraday(basic_auth = false)
        Faraday.new do |conn|
          if basic_auth
            conn.request :authorization, :basic, @app_uuid, @api_key
          end
        end
      end

      def build_headers(basic_auth = false)
        headers = {
          "AcceptEncoding": "gzip, deflate",
          "Accept": "application/json",
          "Content-Type": "application/json",
          "User-Agent": "evervault-ruby/#{VERSION}",
        }
        if !basic_auth
          headers = headers.merge({
            "Api-Key": @api_key,
          })
        end
        headers
      end
    end
  end
end
