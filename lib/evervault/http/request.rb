require "faraday"
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
        execute(:get, build_url(path), params)
      end

      def put(path, params)
        execute(:put, build_url(path), params)
      end

      def delete(path, params)
        execute(:delete, build_url(path), params)
      end

      def post(path, params, options: {}, cage_run: false)
        execute(:post, build_url(path, cage_run), params, build_cage_run_headers(options, cage_run))
      end

      private def build_url(path, cage_run = false)
        return "#{@base_url}#{path}" unless cage_run
        "#{@cage_run_url}#{path}"
      end

      def execute(method, url, params, optional_headers = {})
        resp = Faraday.send(method, url) do |req|
            req.body = params.nil? || params.empty? ? nil : params.to_json
            req.headers = build_headers(optional_headers)
        end
        return JSON.parse(resp.body) if resp.status >= 200 && resp.status <= 300
        Evervault::Errors::ErrorMap.raise_errors_on_failure(resp.status, resp.body)
      end

      private def build_headers(optional_headers)
        optional_headers.merge({
          "AcceptEncoding": "gzip, deflate",
          "Accept": "application/json",
          "Content-Type": "application/json",
          "User-Agent": "evervault-ruby/#{VERSION}",
          "Api-Key": @api_key
        })
      end

      private def build_cage_run_headers(options, cage_run = false)
        optional_headers = {}
        return optional_headers unless cage_run
        if options.key?(:async)
          if options[:async]
            optional_headers["x-async"] = "true"
          end
          options.delete(:async)
        end
        if options.key?(:version)
          if options[:version].is_a? Integer
            optional_headers["x-version-id"] = options[:version].to_s
          end
          options.delete(:version)
        end
        optional_headers.merge(options)
      end
    end
  end
end
