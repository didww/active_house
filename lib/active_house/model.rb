require_relative 'scoping'
require_relative 'querying'
require_relative 'modeling'
require_relative 'connecting'
require_relative 'logger'
require 'active_model/conversion'
require 'active_model/naming'

module ActiveHouse
  class Model
    include ActiveHouse::Scoping
    include ActiveHouse::Querying
    include ActiveHouse::Modeling
    include ActiveHouse::Connecting
    include ActiveHouse::Logger
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    class_attribute :_table_name, instance_accessor: false

    class << self
      def table_name(name)
        self._table_name = name.to_s
      end
    end
  end
end
