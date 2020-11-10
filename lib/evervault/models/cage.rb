module Evervault
  module Models
    class Cage

      attr_reader :name, :uuid
      def initialize(name:, uuid:, request:)
        @name = name
        @uuid = uuid
        @request = request
      end

      def run(params, options = {})
        @request.post(self.name, params, options: options, cage_run: true)
      end

    end
  end
end
