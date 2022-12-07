class RelayOutboundConfig

    DEFAULT_POLL_INTERVAL = 5
    RELAY_OUTBOUND_CONFIG_API_ENDPOINT = "/v2/relay-outbound"

    @@destination_domains_cache = nil
    @@timer = nil

    def initialize(request_handler)
        @request_handler = request_handler
        if @@timer.nil?
            @@timer = RepeatedTimer.new(DEFAULT_POLL_INTERVAL, self.get_relay_outbound_config)
        end
        if @@destination_domains_cache.nil?
            self.get_relay_outbound_config
    end

    def get_destination_domains
        @@destination_domains_cache
    end

    def disable_polling
        if @@timer
            @@timer.stop
    end

    def clear_cache
        @@destination_domains_cache = nil
    end

    private def get_relay_outbound_config
        @request_handler.get(RELAY_OUTBOUND_CONFIG_API_ENDPOINT)
        poll_interval = "5"
        unless @@timer.nil? || poll_interval.nil?
            @@timer.update_interval(poll_interval)
        @@destination_domains_cache = response["destinationDomains"].values.map(&:destinationDomain)
    end
end