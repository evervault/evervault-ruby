require "faraday"
require "json"
require "tempfile"
require "openssl"
require 'net/http'
require_relative "../version"
require_relative "../errors/errors"
# require_relative "../http/relay_outbound_config"

module NetHTTPOverride
  @@api_key = nil
  @@relay_url = nil
  @@relay_port = nil
  @@cert = nil
  @@get_decryption_domains_func = nil
  @@get_decryption_domain_regexes_func = nil

  def self.set_api_key(value)
    @@api_key = value
  end

  def self.set_relay_url(value)
    relay_address_and_port = value.gsub(/(^\w+:|^)\/\//, '').split(":")
    @@relay_url = relay_address_and_port[0]
    @@relay_port = relay_address_and_port[1]
  end

  def self.set_cert(value)
    @@cert = value
  end

  def self.add_get_decryption_domains_func(get_decryption_domains_func)
    @@get_decryption_domains_func = get_decryption_domains_func
    @@get_decryption_domain_regexes_func = get_decryption_domains_func && lambda {
      @@get_decryption_domains_func.call().map {
        |pattern|  Evervault::Http::RelayOutboundConfig.build_domain_regex_from_pattern(pattern)
      }
    }
  end

  def self.add_get_decryption_domain_regexes_func(get_decryption_domain_regexes_func)
    @@get_decryption_domain_regexes_func = get_decryption_domain_regexes_func
  end

  def self.should_decrypt(domain)
    if @@get_decryption_domain_regexes_func.nil?
      return false
    else
      return @@get_decryption_domain_regexes_func.call().any? {
        |decryption_domain_regex| decryption_domain_regex.match(domain)
      }
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
    if should_decrypt
      req["Proxy-Authorization"] = @@api_key
      puts "API KEY IS #{@@api_key}"
    end
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
      def initialize(request:, ca_host:, api_key:, base_url:, relay_url:)
        NetHTTPOverride.set_api_key(api_key)
        NetHTTPOverride.set_relay_url(relay_url)
        
        @request = request
        @base_url = base_url
        @ca_host = ca_host
        @expire_date = nil
        @initial_date = nil
      end

      def is_certificate_expired()
        if @expire_date
          now = Time.now
          if now > @expire_date || now < @initial_date
            return true
          end
        end
        return false
      end

      def setup_decryption_domains(decryption_domains)
        NetHTTPOverride.add_get_decryption_domains_func(-> {
          decryption_domains
        })
        decryption_domain_regexes = decryption_domains.map{
          |pattern| Evervault::Http::RelayOutboundConfig.build_domain_regex_from_pattern(pattern)
        }
        NetHTTPOverride.add_get_decryption_domain_regexes_func(-> {
          decryption_domain_regexes
        })
      end

      def setup_outbound_relay_config
        @relay_outbound_config = Evervault::Http::RelayOutboundConfig.new(base_url: @base_url, request: @request)
        NetHTTPOverride.add_get_decryption_domains_func(-> {
          @relay_outbound_config.get_destination_domains
        })
        NetHTTPOverride.add_get_decryption_domain_regexes_func(-> {
          @relay_outbound_config.get_destination_domain_regexes
        })
      end

      def setup
        get_cert()
      end

      def get_cert()
        ca_content = nil
        i = 0

        while !ca_content && i < 1
          i += 1
          begin
            ca_content = @request.execute("get", @ca_host, nil, {}).body
          rescue;
          end
        end

        if !ca_content || ca_content == ""
          raise Evervault::Errors::CertDownloadError.new("Unable to install the Evervault root certificate from #{@ca_host}")
        end

        cert = OpenSSL::X509::Certificate.new ca_content
        set_cert_expire_date(cert)
        NetHTTPOverride.set_cert(cert)
      end

      def set_cert_expire_date(cert)
        begin
          @expire_date = cert.not_after
          @initial_date = cert.not_before
        rescue => exception
          @expire_date = nil
        end
      end
    end
  end
end

