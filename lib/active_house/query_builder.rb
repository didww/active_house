require 'plain_model/querying/base'
require 'plain_model/querying/except'
require 'plain_model/querying/with_model'
require_relative 'querying/select'
require_relative 'querying/from'
require_relative 'querying/where'
require_relative 'querying/order_by'
require_relative 'querying/group_by'
require_relative 'querying/having'
require_relative 'querying/limit'
require_relative 'querying/union'
require_relative 'querying/array_join'
require_relative 'querying/page'
require_relative 'querying/scope'
require_relative 'querying/collect'

module ActiveHouse
  class QueryBuilder
    include PlainModel::Querying::Base
    include PlainModel::Querying::Except
    include PlainModel::Querying::WithModel

    include ActiveHouse::Querying::Select
    include ActiveHouse::Querying::From
    include ActiveHouse::Querying::Where
    include ActiveHouse::Querying::OrderBy
    include ActiveHouse::Querying::GroupBy
    include ActiveHouse::Querying::Having
    include ActiveHouse::Querying::Limit
    include ActiveHouse::Querying::Union
    include ActiveHouse::Querying::ArrayJoin
    include ActiveHouse::Querying::Scope
    include ActiveHouse::Querying::Page
    include ActiveHouse::Querying::Collect

    # allows using query without model_class
    def initialize(model_class = nil)
      super(model_class || ActiveHouse::Model)
    end
  end
end
