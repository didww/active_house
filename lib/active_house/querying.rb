require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module ActiveHouse
  module Querying
    extend ActiveSupport::Concern

    included do
      class_attribute :_query_class, instance_accessor: false
      self._query_class = ActiveHouse::Query
    end

    class_methods do
      delegate :to_a, :select, :where, :group_by, :limit, :order_by, :having, to: :all

      def all
        _query_class.new(self)
      end
    end
  end
end
