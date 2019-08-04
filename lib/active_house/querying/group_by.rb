module ActiveHouse
  module Querying
    module GroupBy
      extend ActiveSupport::Concern

      included do
        private :build_group_by_query_part
      end

      def build_group_by_query_part
        "GROUP BY #{values[:group_by].join(', ')}" unless values[:group_by].empty?
      end

      def initial_values
        super.merge group_by: []
      end

      def group_by!(*fields)
        raise ArgumentError, 'wrong number of arguments' if fields.empty?
        formatted_fields = fields.map(&:to_s)
        values[:group_by] = (values[:group_by] + formatted_fields).uniq
        self
      end

      def group_by(*fields)
        dup.group_by!(*fields)
      end
    end
  end
end
