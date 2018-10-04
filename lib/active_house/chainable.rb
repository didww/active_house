require_relative 'selectable'
require_relative 'fromable'
require_relative 'whereable'
require_relative 'orderable'
require_relative 'groupable'
require_relative 'limitable'
require_relative 'havingable'
require_relative 'unionable'
require_relative 'array_joinable'
require 'active_support/concern'

module ActiveHouse
  module Chainable
    extend ActiveSupport::Concern

    include ActiveHouse::Selectable
    include ActiveHouse::Fromable
    include ActiveHouse::Whereable
    include ActiveHouse::Orderable
    include ActiveHouse::Groupable
    include ActiveHouse::Havingable
    include ActiveHouse::Limitable
    include ActiveHouse::Unionable
    include ActiveHouse::ArrayJoinable

    included do
      protected

      def data
        chain_methods.values.map { |var| [var, instance_variable_get(:"@#{var}")] }.to_h
      end

      def data=(other_data)
        chain_methods.values.each do |var|
          value = other_data.fetch(var)
          instance_variable_set(:"@#{var}", value.nil? ? nil : value.dup)
        end
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

      private

      # By default each chain method (select, where, group_by) returns new instance of query
      # but in some cases we need to modify and return existing query object
      # (for example when we apply default_scope on query initialize).
      # For this you need just to wrap code that appends chain methods with #with_current_query.
      # Example:
      #
      #   scope1 = SomeModel.all # object id #1
      #   scope2 = scope1.where(id: 3) # object id #2
      #   scope3 = scope2.send(:with_current_query) { scope2.where(success: true) } # object id #2
      #
      def with_current_query
        @_with_current_query = true
        yield
      ensure
        @_with_current_query = false
      end

      def chain_query(options = {})
        options.assert_valid_keys(*chain_methods.values)
        if @_with_current_query
          self.data = data.merge(options)
          self
        else
          new_instance = self.class.new(model_class)
          new_instance.data = data.merge(options)
          new_instance
        end
      end
    end

    def initialize(*)
      @_with_current_query = false
      super
    end

    # key - chain method name
    # value - instance variable name that which store values
    def chain_methods
      {
          select: :fields,
          where: :conditions,
          group_by: :grouping,
          order_by: :ordering,
          limit: :limit,
          having: :having,
          union: :unions,
          from: :subquery,
          array_join: :array_joins
      }
    end

    # key - instance variable name that which store values
    # value - default value for the variable
    def chain_defaults
      {
          fields: [],
          conditions: [],
          grouping: [],
          ordering: [],
          limit: { offset: nil, limit: nil },
          having: [],
          union: {},
          subquery: nil,
          array_joins: []
      }
    end

    def except(*values)
      raise ArgumentError, 'wrong number of arguments' if values.empty?
      not_allowed = values - chain_methods.keys
      unless not_allowed.empty?
        raise ArgumentError, "Values #{not_allowed} are not allowed, allowed only #{chain_methods.keys}."
      end

      new_data = {}
      chain_methods.each do |meth, var|
        new_data[var] = chain_defaults[var].dup if values.include?(meth)
      end
      chain_query(new_data)
    end

    def to_query
      build_query
    end

    def dup
      chain_query
    end

    alias clone dup
  end
end
