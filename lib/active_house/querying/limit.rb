module ActiveHouse
  module Querying
    module Limit
      extend ActiveSupport::Concern

      included do
        private :build_limit_query_part
      end

      def build_limit_query_part
        return if values[:limit].nil?

        parts = ["LIMIT #{values[:limit]}"]
        parts << "OFFSET #{values[:offset]}" if values[:offset] && values[:offset] != 0
        parts << "BY #{values[:limit_by]}" if values[:limit_by]
        parts.join(' ')
      end

      def initial_values
        super.merge offset: nil, limit: nil, limit_by: nil
      end

      def limit!(limit_value, offset_value = nil, limit_by = nil)
        values[:limit] = limit_value
        values[:offset] = offset_value unless offset_value.nil?
        values[:limit_by] = limit_by unless limit_by.nil?
        self
      end

      def limit(limit_value, offset_value = nil, limit_by = nil)
        dup.limit!(limit_value, offset_value, limit_by)
      end
    end
  end
end
