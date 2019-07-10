module ActiveHouse
  module ArrayJoinable
    extend ActiveSupport::Concern

    included do
      private

      def build_array_join_query_part
        "ARRAY JOIN #{@array_joins.join(', ')}" unless @array_joins.empty?
      end
    end

    def initialize(*)
      @array_joins = []
      super
    end

    def array_join(*fields)
      raise ArgumentError, 'wrong number of arguments' if fields.empty?
      formatted_fields = fields.map do |field|
        if field.is_a?(Symbol) && model_class._attribute_opts.key?(field)
          opts = model_class._attribute_opts.fetch(field)
          opts.key?(:select) ? "#{opts[:select]} AS #{field}" : field.to_s
        else
          field.to_s
        end
      end
      chain_query array_joins: (@array_joins + formatted_fields).uniq
    end
  end
end
