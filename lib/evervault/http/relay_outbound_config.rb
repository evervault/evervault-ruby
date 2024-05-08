# frozen_string_literal: true

module Evervault
  module Http
    class RelayOutboundConfig
      DEFAULT_POLL_INTERVAL = 5
      RELAY_OUTBOUND_CONFIG_API_ENDPOINT = 'v2/relay-outbound'

      @@destination_domains_cache = nil
      @@poll_interval = DEFAULT_POLL_INTERVAL
      @@timer = nil

      def initialize(base_url:, request:)
        @base_url = base_url
        @request = request
        get_relay_outbound_config if @@destination_domains_cache.nil?
        return unless @@timer.nil?

        @@timer = Evervault::Threading::RepeatedTimer.new(@@poll_interval, -> { get_relay_outbound_config })
      end

      def get_destination_domains
        @@destination_domains_cache
      end

      def self.disable_polling
        return if @@timer.nil?

        @@timer.stop
        @@timer = nil
      end

      def self.clear_cache
        @@destination_domains_cache = nil
      end

      private

      def get_relay_outbound_config
        resp = @request.execute(:get, "#{@base_url}#{RELAY_OUTBOUND_CONFIG_API_ENDPOINT}")
        poll_interval = resp.headers['x-poll-interval']
        update_poll_interval(poll_interval.to_f) unless poll_interval.nil?
        resp_body = JSON.parse(resp.body)
        @@destination_domains_cache = resp_body['outboundDestinations'].values.map do |outbound_destination|
          outbound_destination['destinationDomain']
        end
      end

      def update_poll_interval(poll_interval)
        @@poll_interval = poll_interval
        return if @@timer.nil?

        @@timer.update_interval(poll_interval)
      end
    end
  end
end
