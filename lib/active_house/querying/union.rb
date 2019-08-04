module ActiveHouse
  module Querying
    module Union
      extend ActiveSupport::Concern

      included do
        private :build_union_query_part, :format_unions
      end

      def build_union_query_part
        return if values[:union].values.empty?

        "UNION ALL\n#{values[:union].values.map(&:to_query).join("\n")}"
      end

      def initial_values
        super.merge union: {}
      end

      # @param queries [Hash] - hash where key is union name and value is a query
      # key needed for possibility to update/replace union query
      def union!(queries)
        formatted_queries = format_unions(queries)
        values[:union] = formatted_queries
        self
      end

      # @param queries [Hash] - hash where key is union name and value is a query
      # key needed for possibility to update/replace union query
      def union(queries)
        dup.union!(queries)
      end

      def update_union(name)
        name = name.to_sym
        raise ArgumentError, "can't find union by name #{name}" unless values[:union].key?(name)
        new_union = yield values[:union][name.to_sym]
        union(name.to_sym => new_union)
      end

      def except_union!(name)
        new_unions = values[:union].map { |n, q| [n, q.dup] }.to_h
        new_unions.delete(name.to_sym)
        values[:union] = new_unions
        self
      end

      def except_union(name)
        dup.except_union!(name)
      end

      def format_unions(queries)
        raise ArgumentError, 'unions must be a Hash' unless queries.is_a?(Hash)
        raise ArgumentError, 'unions hash is empty' if queries.empty?

        new_unions = values[:union].map { |n, q| [n, q.dup] }.to_h

        queries.each do |name, query|
          query = query.all if query.is_a?(ActiveHouse::Model)
          new_unions[name.to_sym] = query.dup
        end

        new_unions
      end
    end
  end
end
