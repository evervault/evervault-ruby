class RelayOutboundConfig

    DEFAULT_POLL_INTERVAL = 5

    @@destination_domains_cache = nil
    @@timer = nil

    def initialize(request_handler)
        @request_handler = request_handler
        if @@destination_domains_cache.nil?
            self.get_relay_outbound_config
        if @@timer.nil?
            @@timer = RepeatedTimer.new(DEFAULT_POLL_INTERVAL, self.get_relay_outbound_config)
        end
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

    def get_relay_outbound_config
        @request_handler.get("/v2/relay-outbound")
    end
end