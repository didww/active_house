require_relative 'chainable'
require_relative 'scopeable'
require_relative 'collectable'

module ActiveHouse
  class Query
    attr_reader :model_class

    def initialize(model_class = ActiveHouse::Model)
      @model_class = model_class
      super()
    end

    def connection
      model_class.connection
    end

    include ActiveHouse::Chainable
    include ActiveHouse::Collectable
    include ActiveHouse::Scopeable
  end
end
