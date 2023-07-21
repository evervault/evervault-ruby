require 'digest'

module Evervault
  module Utils
    class ValidationUtils

      def self.validate_app_uuid_and_api_key(app_uuid, api_key)
        if app_uuid.nil?
          raise Evervault::Errors::AuthenticationError.new(
            "No App ID provided. The App ID can be retrieved in the Evervault dashboard (App Settings)."
          )
        end
        if api_key.nil?
          raise Evervault::Errors::AuthenticationError.new(
            "The provided App ID is invalid. The App ID can be retrieved in the Evervault dashboard (App Settings)."
          )
        end
        if api_key.start_with?('ev:key')
          # Scoped API key
          app_uuid_hash = Digest::SHA512.base64digest(app_uuid)[0, 6]
          app_uuid_hash_from_api_key = api_key.split(':')[4]
          if app_uuid_hash != app_uuid_hash_from_api_key
            raise Evervault::Errors::AuthenticationError.new(
              "The API key is not valid for app #{app_uuid}. Make sure to use an API key belonging to the app #{app_uuid}."
            )
          end
        end
      end
    end
  end
end