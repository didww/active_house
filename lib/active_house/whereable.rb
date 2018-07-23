require_relative 'prepared_statement'
require 'active_support/core_ext/array/wrap'

module ActiveHouse
  module Whereable
    extend ActiveSupport::Concern

    included do
      private

      def format_condition_value(value)
        ActiveHouse::PreparedStatement.format_value(value)
      end

      def format_condition(*conditions)
        raise ArgumentError, 'wrong number of arguments' if conditions.empty?
        return ActiveHouse::PreparedStatement.prepare_sql(*conditions) if conditions.size > 1
        condition = conditions.first
        if condition.is_a?(Hash)
          condition.map do |field, value|
            "#{field} #{sign_for_condition(value)} #{ActiveHouse::PreparedStatement.format_value(value)}"
          end
        else
          condition.to_s
        end
      end

      def sign_for_condition(value)
        if value.is_a?(Array)
          'IN'
        elsif value.nil?
          'IS'
        else
          '='
        end
      end

      def build_where_query_part
        "WHERE\n" + @conditions.join(" AND\n") unless @conditions.empty?
      end
    end

    def initialize(*)
      @conditions = []
      super
    end

    def where(*conditions)
      raise ArgumentError, 'wrong number of arguments' if conditions.empty?
      formatted_conditions = Array.wrap(format_condition(*conditions))
      chain_query conditions: (@conditions + formatted_conditions).uniq
    end
  end
end
