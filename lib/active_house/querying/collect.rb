require 'active_support/concern'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/module/delegation'
require_relative '../search'
require_relative '../search_query'

module ActiveHouse
  module Querying
    module Collect
      extend ActiveSupport::Concern

      included do
        private :collection, :fetch_collection, :query_parts, :build_query
        instance_delegate [:connection] => :model_class
        instance_delegate [
            :each,
            :size,
            :count,
            :map,
            :collect,
            :detect,
            :filter,
            :reject,
            :inject,
            :reduce,
            :all?,
            :any?
        ] => :to_a
      end

      def initialize(*)
        @collection = nil
        super
      end

      def to_a
        collection
      end

      def reset
        @collection = nil
      end

      def loaded?
        !@collection.nil?
      end

      def to_hashes
        connection.select_rows(build_query.squish)
      end

      def to_query
        build_query
      end

      def collection
        @collection ||= fetch_collection
      end

      def fetch_collection
        to_hashes.map { |row| model_class.load!(row) }
      end

      def query_parts
        [
            build_select_query_part,
            build_from_query_part,
            build_array_join_query_part,
            build_where_query_part,
            build_group_by_query_part,
            build_having_query_part,
            build_order_by_query_part,
            build_limit_query_part,
            build_union_query_part
        ]
      end

      def build_query
        query_parts.reject(&:nil?).join("\n")
      end

      def klass
        model_class
      end

      def group_values
        values[:group_by].empty? ? nil : values[:group_by]
      end

      def count(value = 'COUNT() AS cnt')
        return 0 if group_values
        except(:select, :limit, :offset, :order).select(value).to_hashes.first.values.first
      end

    end
  end
end
