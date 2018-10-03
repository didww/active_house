require 'active_support/core_ext/object/try'

module ActiveHouse
  module Orderable
    extend ActiveSupport::Concern

    included do
      private

      def build_order_by_query_part
        "ORDER BY #{@ordering.join(', ')}" unless @ordering.empty?
      end
    end

    def initialize(*)
      @ordering = []
      super
    end

    def order_by(*clauses)
      raise ArgumentError, 'wrong number of arguments' if clauses.empty?
      formatter_clauses = clauses.map do |clause|
        if clause.is_a?(String)
          clause
        elsif clause.is_a?(Symbol)
          clause.to_s
        elsif clause.is_a?(Hash)
          if clause.keys.one?
            direction = clause.values.first
            raise ArgumentError, 'direction must be asc or desc' unless [:asc, :desc].include?(direction.try!(:to_sym))
            "#{clause.keys.first} #{direction.to_s.upcase}"
          else
            clause.assert_valid_keys(:field, :direction, :collate)
            [
                clause.fetch(:field),
                clause[:direction].try!(:to_s).try!(:upcase),
                clause.key?(:collate) ? "COLLATE '#{clause[:collate]}'" : nil
            ].reject(&:nil?).join(' ')
          end
        end
      end
      chain_query ordering: (@ordering + formatter_clauses).uniq
    end
  end
end
