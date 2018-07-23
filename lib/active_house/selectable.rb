module ActiveHouse
  module Selectable
    extend ActiveSupport::Concern

    included do
      private

      def build_select_query_part
        if !@fields.empty?
          query_data = ['SELECT']
          query_data.concat @fields
        else
          query_data = ['SELECT *']
        end
        query_data.join("\n")
      end
    end

    def initialize(*)
      @fields = []
      super
    end

    def select(*fields)
      raise ArgumentError, 'wrong number of arguments' if fields.empty?
      formatted_fields = fields.map do |field|
        if field.is_a?(Symbol) && model_class._attribute_opts.key?(field)
          opts = model_class._attribute_opts.fetch(field)
          opts.key?(:select) ? "#{opts[:select]} AS #{field}" : field.to_s
        else
          field.to_s
        end
      end
      chain_query fields: (@fields + formatted_fields).uniq
    end
  end
end
