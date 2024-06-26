# frozen_string_literal: true

module Evervault
  module Threading
    class RepeatedTimer
      def initialize(interval, func)
        @thread = nil
        @interval = interval
        @func = func
        start
      end

      def start
        return if running?

        @thread = Thread.new do
          loop do
            sleep @interval
            begin
              @func.call
            rescue StandardError
              # Silently ignore exceptions
            end
          end
        end
      end

      def running?
        !@thread.nil?
      end

      def stop
        @thread.exit
        @thread = nil
      end

      def update_interval(new_interval)
        @interval = new_interval
      end
    end
  end
end
