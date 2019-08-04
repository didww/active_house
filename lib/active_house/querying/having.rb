require_relative '../prepared_statement'
require 'active_support/core_ext/array/wrap'

module ActiveHouse
  module Querying
    module Having
      extend ActiveSupport::Concern

      included do
        private :build_having_query_part, :format_having
      end

      def build_having_query_part
        "HAVING\n" + values[:having].join(" AND\n") unless values[:having].empty?
      end

      def initial_values
        super.merge having: []
      end

      def having!(*conditions)
        formatted_conditions = format_having(conditions)
        values[:having] = (values[:having] + formatted_conditions).uniq
        self
      end

      def having(*conditions)
        dup.having!(*conditions)
      end

      def format_having(conditions)
        raise ArgumentError, 'wrong number of arguments' if conditions.empty?
        raise ArgumentError, 'wrong number of arguments' if conditions.empty?

        return [ActiveHouse::PreparedStatement.prepare_sql(*conditions)] if conditions.size > 1

        ActiveHouse::PreparedStatement.build_condition(conditions.first)
      end
    end
  end
end
