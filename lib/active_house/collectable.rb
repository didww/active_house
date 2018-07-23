require 'active_support/concern'

module ActiveHouse
  module Collectable
    extend ActiveSupport::Concern

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

    def collection
      @collection ||= fetch_collection
    end

    def fetch_collection
      result = connection.select_rows(to_query.squish)
      result.map { |row| model_class.load!(row) }
    end
  end
end
