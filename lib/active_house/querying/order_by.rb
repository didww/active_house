require 'active_support/core_ext/object/try'

module ActiveHouse
  module Querying
    module OrderBy
      extend ActiveSupport::Concern

      included do
        private :build_order_by_query_part
      end

      def build_order_by_query_part
        "ORDER BY #{values[:order_by].join(', ')}" unless values[:order_by].empty?
      end

      def initial_values
        super.merge order_by: []
      end

      def order_by!(*clauses)
        formatter_clauses = format_order_clauses(clauses)
        values[:order_by] = (values[:order_by] + formatter_clauses).uniq
        self
      end

      def order_by(*clauses)
        dup.order_by!(*clauses)
      end

      def format_order_clauses(clauses)
        raise ArgumentError, 'wrong number of arguments' if clauses.empty?

        clauses.map do |clause|
          if clause.is_a?(Hash)
            format_order_hash(clause)
          else
            clause.to_s
          end
        end
      end

      def format_order_hash(clause)
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
  end
end
