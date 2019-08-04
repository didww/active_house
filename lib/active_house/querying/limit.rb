module ActiveHouse
  module Querying
    module Limit
      extend ActiveSupport::Concern

      included do
        private :build_limit_query_part
      end

      def build_limit_query_part
        return if values[:limit].nil?
        if values[:offset]
          "LIMIT #{values[:limit]}, #{values[:offset]}"
        else
          "LIMIT #{values[:limit]}"
        end
      end

      def initial_values
        super.merge offset: nil, limit: nil
        super
      end

      def limit!(limit_value, offset_value = nil)
        values[:limit] = limit_value
        values[:offset] = offset_value unless offset_value.nil?
        self
      end

      def limit(limit_value, offset_value = nil)
        dup.limit!(limit_value, offset_value)
      end
    end
  end
end
