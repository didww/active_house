require_relative '../prepared_statement'

module ActiveHouse
  module Querying
    module Where
      extend ActiveSupport::Concern

      included do
        private :build_where_query_part
      end

      def initial_values
        super.merge where: []
      end

      def build_where_query_part
        "WHERE\n" + values[:where].join(" AND\n") unless values[:where].empty?
      end

      def where!(*conditions)
        formatted_conditions = format_where_clauses(conditions)
        values[:where] = (values[:where] + formatted_conditions).uniq
        self
      end

      def where_not!(*conditions)
        formatted_conditions = format_where_clauses(conditions)
        negative_condition = "NOT (#{formatted_conditions.join(' AND ')})"
        values[:where] = (values[:where] + [negative_condition]).uniq
        self
      end

      def where(*conditions)
        dup.where!(*conditions)
      end

      def where_not(*conditions)
        dup.where_not!(*conditions)
      end

      def format_where_clauses(conditions)
        raise ArgumentError, 'wrong number of arguments' if conditions.empty?

        return [ActiveHouse::PreparedStatement.prepare_sql(*conditions)] if conditions.size > 1

        ActiveHouse::PreparedStatement.build_condition(conditions.first)
      end
    end
  end
end
