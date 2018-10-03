module ActiveHouse
  module Limitable
    extend ActiveSupport::Concern

    included do
      private

      def build_limit_query_part
        return if @limit[:limit].nil?
        if @limit[:offset]
          "LIMIT #{@limit[:limit]}, #{@limit[:offset]}"
        else
          "LIMIT #{@limit[:limit]}"
        end
      end
    end

    def initialize(*)
      @limit = { offset: nil, limit: nil }
      super
    end

    def limit(limit_value, offset_value = nil)
      chain_query limit: { offset: offset_value || @limit[:offset], limit: limit_value }
    end
  end
end
