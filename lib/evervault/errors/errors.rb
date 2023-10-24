module Evervault
  module Errors
    class EvervaultError < StandardError; end

    class ArgumentError < EvervaultError; end

    class HttpError < EvervaultError; end

    class ResourceNotFoundError < EvervaultError; end

    class AuthenticationError < EvervaultError; end

    class ForbiddenError < EvervaultError; end

    class ServerError < EvervaultError; end

    class BadGatewayError < EvervaultError; end

    class ServiceUnavailableError < EvervaultError; end

    class BadRequestError < EvervaultError; end

    class UndefinedDataError < EvervaultError; end

    class InvalidPublicKeyError < EvervaultError; end

    class UnexpectedError < EvervaultError; end

    class CertDownloadError < EvervaultError; end

    class UnsupportedEncryptType < EvervaultError; end

    class DecryptionError < EvervaultError; end

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
