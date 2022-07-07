module Evervault
  module Errors
    class EvervaultError < StandardError; end

    class ArgumentError < EvervaultError; end

    class HttpError < EvervaultError; end

    class ResourceNotFoundError < EvervaultError; end

    class AuthenticationError < EvervaultError; end

    class ServerError < EvervaultError; end

    class BadGatewayError < EvervaultError; end

    class ServiceUnavailableError < EvervaultError; end

    class BadRequestError < EvervaultError; end

    class UndefinedDataError < EvervaultError; end

    class InvalidPublicKeyError < EvervaultError; end

    class UnexpectedError < EvervaultError; end

    class CertDownloadError < EvervaultError; end

    class UnsupportedEncryptType < EvervaultError; end

    class ForbiddenIPError < EvervaultError; end
  end
end
