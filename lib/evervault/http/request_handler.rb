require "faraday"
require "json"
require_relative "../version"
require_relative "../errors/error_map"

module Evervault
  module Http
    class RequestHandler
      def initialize(request:, base_url:, cert:)
        @request = request
        @base_url = base_url
        @cert = cert
      end

      def get(path)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        resp = @request.execute(:get, build_url(path))
        parse_json_body(resp.body)
      end

      def put(path, body)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        resp = @request.execute(:put, build_url(path), body)
        parse_json_body(resp.body)
      end

      def delete(path)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        resp = @request.execute(:delete, build_url(path))
        parse_json_body(resp.body)
      end

      def post(path, body, basic_auth = false, error_map = Evervault::Errors::LegacyErrorMap)
        if @cert.is_certificate_expired()
          @cert.setup()
        end
        resp = @request.execute(:post, build_url(path), body, basic_auth, error_map)
        return parse_json_body(resp.body) unless resp.body.empty?
      end

      private def parse_json_body(body)
        JSON.parse(body)
      end

      private def build_url(path)
        return "#{@base_url}#{path}"
      end
    end
  end
end
