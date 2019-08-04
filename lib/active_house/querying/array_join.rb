module ActiveHouse
  module Querying
    module ArrayJoin
      extend ActiveSupport::Concern

      included do
        private :build_array_join_query_part
      end

      def build_array_join_query_part
        parts = []
        parts << "ARRAY JOIN #{values[:array_join].join(', ')}" unless values[:array_join].empty?
        parts << "LEFT ARRAY JOIN #{values[:array_join].join(', ')}" unless values[:left_array_join].empty?
        parts.join("\n")
      end

      def initial_values
        super.merge array_join: [], left_array_join: []
      end

      def array_join!(*fields)
        formatted_fields = ActiveHouse::PreparedStatement.format_fields(model_class, fields)
        values[:array_join] = (values[:array_join] + formatted_fields).uniq
        self
      end

      def array_join(*fields)
        dup.array_join!(*fields)
      end

      def left_array_join!(*fields)
        formatted_fields = ActiveHouse::PreparedStatement.format_fields(model_class, fields)
        values[:left_array_join] = (values[:left_array_join] + formatted_fields).uniq
        self
      end

      def left_array_join(*fields)
        dup.left_array_join!(*fields)
      end
    end
  end
end
