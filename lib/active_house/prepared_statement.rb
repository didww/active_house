module ActiveHouse
  module PreparedStatement
    def self.prepare_sql(sql, *bindings)
      return sql if bindings.empty?
      parts = sql_parts(sql)
      raise ArgumentError, 'wrong number of bindings' if parts.size != bindings.size + 1
      parts.map.with_index do |part, idx|
        value = idx + 1 > bindings.size ? nil : format_value(bindings[idx])
        "#{part}#{value}"
      end.join
    end

    def self.format_value(value)
      return 'NULL' if value.nil?
      if value.is_a?(Array)
        "(#{value.map { |val| format_value(val) }.join(', ')})"
      elsif value.is_a?(String)
        "'#{value.gsub("'", "\\'")}'"
      elsif value.is_a?(Time)
        if value.respond_to?(:zone)
          "toDateTime('#{value.strftime('%F %T')}', '#{value.zone}')"
        else
          "toDateTime('#{value.strftime('%F %T')}')"
        end
      else
        value.to_s
      end
    end

    def self.sql_parts(sql)
      # TODO: except prepended with backslash or inside brackets
      parts = sql.split('?')
      parts.push('') if sql.end_with?('?')
      parts
    end

    # @param condition [Hash]
    def self.build_condition(condition)
      return [condition.to_s] unless condition.is_a?(Hash)

      condition.map do |field, value|
        "#{field} #{sign_for_condition(value)} #{format_value(value)}"
      end
    end

    def self.sign_for_condition(value)
      if value.is_a?(Array)
        'IN'
      elsif value.nil?
        'IS'
      else
        '='
      end
    end

    def self.format_fields(model_class, fields)
      raise ArgumentError, 'wrong number of arguments' if fields.empty?

      fields.map do |field|
        if field.is_a?(Symbol) && model_class._attribute_opts.key?(field)
          opts = model_class._attribute_opts.fetch(field)
          opts.key?(:select) ? "#{opts[:select]} AS #{field}" : field.to_s
        else
          field.to_s
        end
      end
    end
  end
end
