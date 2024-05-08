# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative '../version'
require_relative '../errors/error_map'

module Evervault
  module Http
    class RequestHandler
      attr_reader :config

      def initialize(request:, config:, cert:)
        @request = request
        @config = config
        @cert = cert
      end

      def get(path)
        @cert.setup if @cert.is_certificate_expired
        resp = @request.execute(:get, build_url(path))
        parse_json_body(resp.body)
      end

      def put(path, body)
        @cert.setup if @cert.is_certificate_expired
        resp = @request.execute(:put, build_url(path), body)
        parse_json_body(resp.body)
      end

      def delete(path)
        @cert.setup if @cert.is_certificate_expired
        resp = @request.execute(:delete, build_url(path))
        parse_json_body(resp.body)
      end

      def post(path, body, basic_auth = false, error_map = Evervault::Errors::LegacyErrorMap)
        @cert.setup if @cert.is_certificate_expired
        resp = @request.execute(:post, build_url(path), body, basic_auth, error_map)
        parse_json_body(resp.body) unless resp.body.empty?
      end

      private

      def parse_json_body(body)
        JSON.parse(body)
      end

      def build_url(path)
        "#{config.base_url}#{path}"
      end
    end
  end
end
