module ActiveHouse
  module Groupable
    extend ActiveSupport::Concern

    included do
      private

      def build_group_by_query_part
        "GROUP BY #{@grouping.join(', ')}" unless @grouping.empty?
      end
    end

    def initialize(*)
      @grouping = []
      super
    end

    def group_by(*fields)
      raise ArgumentError, 'wrong number of arguments' if fields.empty?
      chain_query grouping: (@grouping + fields.map(&:to_s)).uniq
    end
  end
end
