require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module ActiveHouse
  module Modeling
    module Query
      extend ActiveSupport::Concern

      class_methods do
        delegate :select,
                 :array_join,
                 :left_array_join,
                 :group_by,
                 :limit,
                 :order_by,
                 :having,
                 :from,
                 :union,
                 :where,
                 :where_not,
                 to: :all

        def _query_builder
          ::ActiveHouse::QueryBuilder.new(self)
        end
      end
    end
  end
end
