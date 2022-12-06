module Evervault
    module Threading
        class RepeatedTimer
            def initialize(interval, func)
                @thread = nil
                @interval = interval
                @func = func
                self.start
            end

            def start
                if !self.running?
                    @thread = Thread.new do
                        loop do
                            sleep @interval
                            begin 
                                @func.call
                            rescue => e
                                # Silently ignore exemptions
                            end
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
                if new_interval != @interval
                    @interval = new_interval
                    self.stop
                    self.start
                end
            end
        end
    end
end