module ActiveHouse
  module Querying
    module From
      extend ActiveSupport::Concern

      included do
        private :build_from_query_part, :from_subquery
      end

      def from_subquery
        return model_class._table_name if values[:from].nil?
        query = values[:from].is_a?(ActiveHouse::QueryBuilder) ? values[:from].to_query : values[:from].to_s
        "( #{query} )"
      end

      def build_from_query_part
        "FROM #{from_subquery}"
      end

      def from!(table_or_subquery)
        values[:from] = table_or_subquery.dup
        self
      end

      def from(table_or_subquery)
        dup.from!(table_or_subquery)
      end
    end
  end
end
