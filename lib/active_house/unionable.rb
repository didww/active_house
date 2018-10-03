module ActiveHouse
  module Unionable
    extend ActiveSupport::Concern

    included do
      private

      def build_union_query_part
        "UNION ALL\n#{@unions.map(&:to_query).join("\n")}" unless @unions.empty?
      end
    end

    def initialize(*)
      @unions = []
      super
    end

    def union(query)
      query = query.all if query.is_a?(ActiveHouse::Model)
      raise ArgumentError, 'argument must be model or query object' unless query.is_a?(ActiveHouse::Query)
      new_unions = @unions.map(&:dup) + [query.dup]
      chain_query unions: new_unions
    end

    def update_union(index, &block)
      raise ArgumentError, "can't find union by index #{index}" if @unions.size < index + 1
      union = block.call @unions[index].dup
      new_unions = @unions.map(&:dup)
      new_unions[index] = union
      chain_query unions: new_unions
    end

    def union_for(index)
      raise ArgumentError, "can't find union by index #{index}" if @unions.size < index + 1
      @unions[index].dup
    end
  end
end
