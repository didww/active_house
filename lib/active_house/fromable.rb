module ActiveHouse
  module Fromable
    extend ActiveSupport::Concern

    included do
      private

      def from_subquery
        return model_class._table_name if @subquery.nil?
        query = @subquery.is_a?(ActiveHouse::Query) ? @subquery.to_query : @subquery
        "( #{query} )"
      end

      def build_from_query_part
        "FROM #{from_subquery}"
      end
    end

    def initialize(*)
      @subquery = nil
      super
    end

    def from(table_or_subquery)
      raise ArgumentError, '' if !table_or_subquery.is_a?(ActiveHouse::Query) && !table_or_subquery.is_a?(String)
      chain_query subquery: table_or_subquery.dup
    end
  end
end
