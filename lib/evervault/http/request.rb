require "faraday"
require "json"
require_relative "../version"
require_relative "../errors/error_map"

module Evervault
  module Http
    class Request
      def initialize(timeout:, app_uuid:, api_key:)
        @timeout = timeout
        @app_uuid = app_uuid
        @api_key = api_key
      end

      def execute(method, url, params, optional_headers = {})
        resp = faraday.public_send(method, url) do |req|
            req.body = params.nil? || params.empty? ? nil : params.to_json
            req.headers = build_headers(optional_headers)
            req.options.timeout = @timeout
        end

        if resp.status >= 200 && resp.status <= 300
          return resp
        end

        Evervault::Errors::ErrorMap.raise_errors_on_failure(resp.status, resp.body, resp.headers)
      end

      private

      def faraday
        Faraday.new do |conn|
          conn.request :authorization, :basic, @app_uuid, @api_key
        end
      end

      def build_headers(optional_headers)
        optional_headers.merge({
          "AcceptEncoding": "gzip, deflate",
          "Accept": "application/json",
          "Content-Type": "application/json",
          "User-Agent": "evervault-ruby/#{VERSION}",
          "Api-Key": @api_key,
        })
      end
    end
  end
end
