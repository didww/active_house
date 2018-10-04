require 'active_support/concern'
require 'active_support/core_ext/string/filters'

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

    def to_hashes
      connection.select_rows(to_query.squish)
    end

    private

    def collection
      @collection ||= fetch_collection
    end

    def fetch_collection
      to_hashes.map { |row| model_class.load!(row) }
    end
  end
end
