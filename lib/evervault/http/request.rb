require "typhoeus"
require "json"
require_relative "../version"
require_relative "../errors/error_map"

module Evervault
  module Http
    class Request
      def initialize(api_key:, base_url:, cage_run_url:, timeout:)
        @api_key = api_key
        @timeout = timeout
        @base_url = base_url
        @cage_run_url = cage_run_url
      end

      def get(path, params = nil)
        self.execute(:get, self.build_url(path), params)
      end

      def put(path, params)
        self.execute(:put, self.build_url(path), params)
      end

      def delete(path, params)
        self.execute(:delete, self.build_url(path), params)
      end

      def post(path, params, cage_run: false)
        self.execute(:post, self.build_url(path, cage_run), params)
      end

      private def build_url(path, cage_run = false)
        return "#{@base_url}#{path}" unless cage_run
        "#{@cage_run_url}#{path}"
      end

      def execute(method, url, params)
        req =
          Typhoeus::Request.new(
            url,
            method: method, params: params, headers: self.build_headers
          )
        req.on_complete do |response|
          if response.success?
            return JSON.parse(response.body)
          else
            Evervault::Errors::ErrorMap.raise_errors_on_failure(
              response.code,
              response.body
            )
          end
        end
        resp = req.run
      end

      private def build_headers
        {
          "User-Agent": "evervault-ruby/#{VERSION}",
          "AcceptEncoding": "gzip, deflate",
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Api-Key": @api_key
        }
      end
    end
  end
end
