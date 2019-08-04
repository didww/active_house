require 'active_model/conversion'
require 'active_model/naming'
require 'plain_model/modeling/base'
require 'plain_model/modeling/queryable'
require_relative 'modeling/scope'
require_relative 'modeling/query'
require_relative 'modeling/attributes'
require_relative 'modeling/connection'
require_relative 'logging'

module ActiveHouse
  class Model
    extend PlainModel::Modeling::Queryable
    include PlainModel::Modeling::Base
    include ActiveHouse::Modeling::Scope
    include ActiveHouse::Modeling::Query
    include ActiveHouse::Modeling::Attributes
    include ActiveHouse::Modeling::Connection
    include ActiveHouse::Logging

    class_attribute :_table_name, instance_accessor: false

    class << self
      def table_name(name)
        self._table_name = name.to_s
      end
    end
  end
end
