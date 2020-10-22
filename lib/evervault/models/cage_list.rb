require_relative "cage"

module Evervault
  module Models
    class CageList
      attr_reader :cages
      def initialize(cages:, request:)
        @cages = build_cage_list(cages, request)
      end

      def to_hash
        cage_hash = {}
        cages.each { |cage| cage_hash[cage.name] = cage }
        cage_hash
      end

      private def build_cage_list(cages, request)
        cages.map { |cage| Cage.new(name: cage["name"], uuid: cage["uuid"], request: request) }
      end
    end
  end
end
