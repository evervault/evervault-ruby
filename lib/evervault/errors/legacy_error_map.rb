# frozen_string_literal: true

require_relative 'errors'

module Evervault
  module Errors
    class LegacyErrorMap
      def self.raise_errors_on_failure(status_code, body, headers)
        return if status_code < 400

        case status_code
        when 404
          raise EvervaultError, 'Resource not found'
        when 400
          raise EvervaultError, 'Bad request'
        when 401
          raise EvervaultError, 'Unauthorized'
        when 403
          if (headers.include? 'x-evervault-error-code') && (headers['x-evervault-error-code'] == 'forbidden-ip-error')
            raise ForbiddenIPError, 'IP is not present in Cage whitelist'
          end

          raise EvervaultError, 'Forbidden'

        when 500
          raise EvervaultError, 'Server error'
        when 502
          raise EvervaultError, 'Bad gateway error'
        when 503
          raise EvervaultError, 'Service unavailable'
        else
          raise EvervaultError, message_for_unexpected_error_without_type(body)
        end
      end

      private

      def message_for_unexpected_error_without_type(error_details)
        if error_details.nil?
          return(
            'An unexpected error occurred without message or status code. Please contact Evervault support'
          )
        end
        message = error_details['message']
        status_code = error_details['statusCode']
        "An unexpected error occured. It occurred with the message: #{
          message
        } and http_code: '#{status_code}'. Please contact Evervault support"
      end
    end
  end
end
