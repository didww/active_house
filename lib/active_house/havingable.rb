require_relative 'prepared_statement'
require 'active_support/core_ext/array/wrap'

module ActiveHouse
  module Havingable
    extend ActiveSupport::Concern

    included do
      private

      def format_having(*conditions)
        raise ArgumentError, 'wrong number of arguments' if conditions.empty?
        return ActiveHouse::PreparedStatement.prepare_sql(*conditions) if conditions.size > 1
        condition = conditions.first
        if condition.is_a?(Hash)
          condition.map do |field, value|
            "#{field} #{sign_for_having(value)} #{ActiveHouse::PreparedStatement.format_value(value)}"
          end
        else
          condition.to_s
        end
      end

      def sign_for_having(value)
        if value.is_a?(Array)
          'IN'
        elsif value.nil?
          'IS'
        else
          '='
        end
      end

      def build_having_query_part
        "HAVING\n" + @having.join(" AND\n") unless @having.empty?
      end
    end

    def initialize(*)
      @having = []
      super
    end

    def having(*conditions)
      raise ArgumentError, 'wrong number of arguments' if conditions.empty?
      formatted_conditions = Array.wrap(format_having(*conditions))
      chain_query having: (@having + formatted_conditions).uniq
    end
  end
end
