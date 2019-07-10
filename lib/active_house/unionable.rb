module ActiveHouse
  module Unionable
    extend ActiveSupport::Concern

    included do
      private

      def build_union_query_part
        "UNION ALL\n#{@unions.values.map(&:to_query).join("\n")}" unless @unions.values.empty?
      end
    end

    def initialize(*)
      @unions = {}
      super
    end

    def union(name, query)
      query = query.all if query.is_a?(ActiveHouse::Model)
      raise ArgumentError, 'argument must be model or query object' unless query.is_a?(ActiveHouse::Query)
      new_unions = @unions.map { |n, q| [n, q.dup] }.to_h
      new_unions[name] = query.dup
      chain_query unions: new_unions
    end

    def update_union(name)
      raise ArgumentError, "can't find union by name #{name}" unless @unions.key?(name)
      new_union = yield union_for(name)
      union(name, new_union)
    end

    def union_for(name)
      raise ArgumentError, "can't find union by name #{name}" unless @unions.key?(name)
      @unions[name].dup
    end

    def except_union(name)
      new_unions = @unions.map { |n, q| [n, q.dup] }.to_h
      new_unions.delete(name)
      chain_query unions: new_unions
    end
  end
end
