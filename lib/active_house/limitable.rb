module ActiveHouse
  module Limitable
    extend ActiveSupport::Concern

    included do
      private

      def build_limit_query_part
        return if @limit.empty?
        if @limit[1]
          "LIMIT #{@limit[0]}, #{@limit[1]}"
        else
          "LIMIT #{@limit[0]}"
        end
      end
    end

    def initialize(*)
      @limit = []
      super
    end

    def limit(limit_value, offset_value = nil)
      chain_query limit: (@limit + [limit_value, offset_value]).uniq
    end
  end
end
