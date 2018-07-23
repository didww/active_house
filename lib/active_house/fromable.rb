module ActiveHouse
  module Fromable
    extend ActiveSupport::Concern

    included do
      private

      def build_from_query_part
        "FROM #{table_name}"
      end
    end

    def initialize(*)
      @table_name = model_class._table_name
      super
    end

    def table_name
      @table_name
    end
  end
end
