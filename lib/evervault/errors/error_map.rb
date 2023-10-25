require_relative "errors"

module Evervault
  module Errors
    class ErrorMap
      def self.raise_errors_on_failure(status_code, body, headers)
        parsed_body = JSON.parse(body)
        code = parsed_body["code"]
        detail = parsed_body["detail"]

        if code == "unauthorized"
          raise AuthenticationError.new(detail)
        elsif code == "forbidden"
          raise ForbiddenError.new(detail)
        elsif code == "unprocessable-content"
          raise DecryptionError.new(detail)
        elsif code == "invalid-request"
          raise BadRequestError.new(detail)
        elsif code == "functions/request-timeout"
          raise FunctionTimeoutError.new(detail)
        elsif code == "functions/function-not-ready"
          raise FunctionNotReadyError.new(detail)
        elsif code == "functions/forbidden-ip"
          raise ForbiddenIPError.new(detail)
        else
          raise EvervaultError.new(detail)
        end
      end

      def self.raise_function_error_on_failure(body)
        error = body["error"]
        if error
          message = error["message"]
          stack = error["stack"]
          id = body["id"]
          raise FunctionRuntimeError.new(message, stack, id)
        else
          raise EvervaultError.new("An unexpected error occurred. Please contact Evervault support")
        end
      end
    end
  end
end
