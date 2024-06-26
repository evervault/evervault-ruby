# frozen_string_literal: true

require 'faraday'
require 'json'
require 'tempfile'
require 'openssl'
require 'net/http'
require_relative '../version'
require_relative '../errors/errors'

module NetHTTPOverride
  @@api_key = nil
  @@relay_url = nil
  @@relay_port = nil
  @@cert = nil
  @@get_decryption_domains_func = nil

  def self.set_api_key(value)
    @@api_key = value
  end

  def self.set_relay_url(value)
    relay_address_and_port = value.gsub(%r{(^\w+:|^)//}, '').split(':')
    @@relay_url = relay_address_and_port[0]
    @@relay_port = relay_address_and_port[1]
  end

  def self.set_cert(value)
    @@cert = value
  end

  def self.add_get_decryption_domains_func(get_decryption_domains_func)
    @@get_decryption_domains_func = get_decryption_domains_func
  end

  def self.should_decrypt(domain)
    if @@get_decryption_domains_func.nil?
      false
    else
      decryption_domains = @@get_decryption_domains_func.call
      decryption_domains.any? do |decryption_domain|
        if decryption_domain.start_with?('*')
          domain.end_with?(decryption_domain[1..])
        else
          domain == decryption_domain
        end
      end
    end
  end

  def connect_with_intercept
    if NetHTTPOverride.should_decrypt(conn_address)
      @cert_store = OpenSSL::X509::Store.new
      @cert_store.add_cert(@@cert)
      @proxy_from_env = false
      @proxy_address = @@relay_url
      @proxy_port = @@relay_port
    end
    connect_without_intercept
  end

  def request_with_intercept(req, body = nil, &block)
    should_decrypt = NetHTTPOverride.should_decrypt(@address)
    req['Proxy-Authorization'] = @@api_key if should_decrypt
    request_without_intercept(req, body, &block)
  end
end

Net::HTTP.class_eval do
  include NetHTTPOverride
  alias_method :request_without_intercept, :request
  alias_method :request, :request_with_intercept
  alias_method :connect_without_intercept, :connect
  alias_method :connect, :connect_with_intercept
end

module Evervault
  module Http
    class RequestIntercept
      attr_reader :config

      def initialize(request:, config:)
        @config = config
        NetHTTPOverride.set_api_key(config.api_key)
        NetHTTPOverride.set_relay_url(config.relay_url)

        @request = request
        @expire_date = nil
        @initial_date = nil
      end

      def is_certificate_expired
        if @expire_date
          now = Time.now
          return true if now > @expire_date || now < @initial_date
        end
        false
      end

      def setup_decryption_domains(decryption_domains)
        NetHTTPOverride.add_get_decryption_domains_func(lambda {
          decryption_domains
        })
      end

      def setup_outbound_relay_config
        @relay_outbound_config = Evervault::Http::RelayOutboundConfig.new(base_url: config.base_url, request: @request)
        NetHTTPOverride.add_get_decryption_domains_func(lambda {
          @relay_outbound_config.get_destination_domains
        })
      end

      def setup
        get_cert
      end

      def get_cert
        ca_content = nil
        i = 0

        while !ca_content && i < 1
          i += 1
          begin
            ca_content = @request.execute('get', config.ca_host).body
          rescue StandardError
          end
        end

        if !ca_content || ca_content == ''
          raise Evervault::Errors::EvervaultError,
                "Unable to install the Evervault root certificate from #{config.ca_host}"
        end

        cert = OpenSSL::X509::Certificate.new ca_content
        set_cert_expire_date(cert)
        NetHTTPOverride.set_cert(cert)
      end

      def set_cert_expire_date(cert)
        @expire_date = cert.not_after
        @initial_date = cert.not_before
      rescue StandardError
        @expire_date = nil
      end
    end
  end
end
