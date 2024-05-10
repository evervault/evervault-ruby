# frozen_string_literal: true

require_relative 'errors'

module Evervault
  module Errors
    class ErrorMap
      def self.raise_errors_on_failure(_status_code, body, _headers)
        parsed_body = JSON.parse(body)
        code = parsed_body['code']
        detail = parsed_body['detail']

        case code
        when 'functions/request-timeout'
          raise FunctionTimeoutError, detail
        when 'functions/function-not-ready'
          raise FunctionNotReadyError, detail
        when 'functions/forbidden-ip'
          raise ForbiddenIPError, detail
        else
          raise EvervaultError, detail
        end
      end

      def self.raise_function_error_on_failure(body)
        error = body['error']
        raise EvervaultError, 'An unexpected error occurred. Please contact Evervault support' unless error

        message = error['message']
        stack = error['stack']
        id = body['id']
        raise FunctionRuntimeError.new(message, stack, id)
      end
    end
  end
end
