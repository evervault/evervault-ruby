require "faraday"
require "json"
require_relative "../version"
require_relative "../errors/error_map"

module Evervault
  module Http
    class RequestHandler
      def initialize(request:, base_url:, cage_run_url:, cert:)
        @request = request
        @base_url = base_url
        @cage_run_url = cage_run_url
        @cert = cert
      end

      def get(path, params = nil)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        @request.execute(:get, build_url(path), params)
      end

      def put(path, params)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        @request.execute(:put, build_url(path), params)
      end

      def delete(path, params)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        @request.execute(:delete, build_url(path), params)
      end

      def post(path, params, options: {}, cage_run: false)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        @request.execute(:post, build_url(path, cage_run), params, build_cage_run_headers(options, cage_run))
      end

      private def build_url(path, cage_run = false)
        return "#{@base_url}#{path}" unless cage_run
        "#{@cage_run_url}#{path}"
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
