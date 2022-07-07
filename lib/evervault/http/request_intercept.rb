require "faraday"
require "json"
require "tempfile"
require "openssl"
require 'net/http'
require_relative "../version"
require_relative "../errors/errors"

module NetHTTPOverride
  @@api_key = nil
  @@relay_url = nil
  @@relay_port = nil
  @@cert = nil
  @@decrypt_if_exact = []
  @@decrypt_if_ends_with = []

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

  def self.add_to_decrypt_if_exact(value)
    @@decrypt_if_exact.append(value)
  end

  def self.add_to_decrypt_if_ends_with(value)
    @@decrypt_if_ends_with.append(value)
  end

  def should_decrypt(domain)
    return (@@decrypt_if_exact.include? domain) || (@@decrypt_if_ends_with.any? { |suffix| domain.end_with? suffix })
  end

  def connect
    if should_decrypt(conn_address)
      @cert_store = OpenSSL::X509::Store.new
      @cert_store.add_cert(@@cert)
      @proxy_from_env = false
      @proxy_address = @@relay_url
      @proxy_port = @@relay_port
    end
    super
  end

  def request(req, body = nil, &block)
    should_decrypt = should_decrypt(@address)
    if should_decrypt
      req["Proxy-Authorization"] = @@api_key
    end
    super
  end
end

Net::HTTP.send :prepend, NetHTTPOverride

module Evervault
  module Http
    class RequestIntercept
      def initialize(request:, ca_host:, api_key:, relay_url:)
        NetHTTPOverride.set_api_key(api_key)
        NetHTTPOverride.set_relay_url(relay_url)
        
        @request = request
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

      def setup_domains(decrypt_domains=[])
        for domain in decrypt_domains
          if domain.start_with?("www.")
            domain = domain[4..-1]
          end
          NetHTTPOverride.add_to_decrypt_if_exact(domain)
          NetHTTPOverride.add_to_decrypt_if_ends_with("." + domain)
          NetHTTPOverride.add_to_decrypt_if_ends_with("@" + domain)
        end
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
            ca_content = @request.execute("get", @ca_host, nil, {}, is_ca: true)
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

