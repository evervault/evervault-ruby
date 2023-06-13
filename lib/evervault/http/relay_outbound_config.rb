module Evervault
  module Http
    class RelayOutboundConfig
      DEFAULT_POLL_INTERVAL = 5
      RELAY_OUTBOUND_CONFIG_API_ENDPOINT = "v2/relay-outbound"

      @@destination_domains_cache = nil
      @@destination_domain_regexes = nil
      @@poll_interval = DEFAULT_POLL_INTERVAL
      @@timer = nil

      def initialize(base_url:, request:)
        @base_url = base_url
        @request = request
        if @@destination_domains_cache.nil?
          get_relay_outbound_config
        end
        if @@timer.nil?
          @@timer = Evervault::Threading::RepeatedTimer.new(@@poll_interval, -> { get_relay_outbound_config })
        end
      end

      def get_destination_domains
        @@destination_domains_cache
      end

      def get_destination_domain_regexes
        @@destination_domain_regexes
      end

      def self.build_domain_regex_from_pattern(pattern)
        regex = pattern \
          .gsub(/(?<!\*)\*\*+\./, '*') \
          .gsub(/\./, '\\.') \
          .gsub(/(?<!\*)\*+/, '.*') \
          .gsub(/(\.\*)([^\\*.])/, '\1(^|\\.)\2')
        /^#{regex}$/i
      end

      def self.disable_polling
        unless @@timer.nil?
          @@timer.stop
          @@timer = nil
        end
      end

      def self.clear_cache
        @@destination_domains_cache = nil
      end

      private def get_relay_outbound_config
        resp = @request.execute(:get, "#{@base_url}#{RELAY_OUTBOUND_CONFIG_API_ENDPOINT}", nil)
        poll_interval = resp.headers["x-poll-interval"]
        unless poll_interval.nil?
          update_poll_interval(poll_interval.to_f)
        end
        resp_body = JSON.parse(resp.body)
        @@destination_domains_cache = resp_body["outboundDestinations"].values.map{ |outbound_destination| outbound_destination["destinationDomain"] }
        @@destination_domain_regexes = @@destination_domains_cache.map{
          |destination_domain| Evervault::Http::RelayOutboundConfig.build_domain_regex_from_pattern(destination_domain)
        }
      end

      private def update_poll_interval(poll_interval)
        @@poll_interval = poll_interval
        unless @@timer.nil?
          @@timer.update_interval(poll_interval)
        end
      end
    end
  end
end
