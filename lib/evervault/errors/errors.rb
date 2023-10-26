module Evervault
  module Errors
    class EvervaultError < StandardError; end

    class FunctionError < EvervaultError; end

    class ForbiddenIPError < FunctionError; end

    class FunctionTimeoutError < FunctionError; end

    class FunctionNotReadyError < FunctionError; end

    class FunctionRuntimeError < FunctionError
      attr_reader :message, :stack, :id
    
      def initialize(message, stack, id)
        @message = message
        @stack = stack
        @id = id
        super("#{message}")
      end
    end

  end
end
