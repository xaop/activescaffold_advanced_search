module ActiveScaffold

  module AdvancedFinder
    
    def self.create_conditions_for_columns(columns, fields, modes, values)
      columns_hash = columns.inject({}) { |h, c| h[c.name.to_s] = c ; h }
      
      # if there aren't any columns, then just return a nil condition
      return if (columns_hash.keys & fields).empty?

      where_clauses = []
      tokens = []
      fields.zip(modes).zip(values).each do |(f, m), v|
        if c = columns_hash[f]
          search_sql = "LOWER(#{c.search_sql})"
          v = (v || '').downcase
          case m
          when "equals"
            where_clauses << "#{search_sql} = ?"
            tokens << v
          when "contains"
            where_clauses << "#{search_sql} LIKE ?"
            tokens << "%#{v}%"
          when "starts"
            where_clauses << "#{search_sql} LIKE ?"
            tokens << "#{v}%"
          when "ends"
            where_clauses << "#{search_sql} LIKE ?"
            tokens << "%#{v}"
          else
            raise "not yet #{m}"
          end
        end
      end
      
      [where_clauses.join(" AND "), *tokens]
    end

  end

end
