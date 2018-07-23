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
      sql
    end

    def self.format_value(value)
      return 'NULL' if value.nil?
      if value.is_a?(Array)
        "(#{value.map { |val| format_value(val) }.join(', ')})"
      elsif value.is_a?(String)
        "'#{value.gsub("'", "\\'")}'"
      elsif value.is_a?(Time)
        if value.respond_to?(:zone)
          "toDateTime('#{value.strftime('%Y-%m-%d %H:%M:%S')}', '#{value.zone}')"
        else
          "toDateTime('#{value.strftime('%Y-%m-%d %H:%M:%S')}')"
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
  end
end
