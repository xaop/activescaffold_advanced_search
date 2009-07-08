module ActiveScaffold

  module AdvancedFinder
    
    def self.create_conditions_for_columns(columns, fields, negators, modes, values, boolean_modes, integer_modes, integer_values)
      columns_hash = columns.inject({}) { |h, c| h[c.name.to_s] = c ; h }
      
      # if there aren't any columns, then just return a nil condition
      return if (columns_hash.keys & fields).empty?

      where_clauses = []
      tokens = []
      fields.zip(negators, modes, values, boolean_modes, integer_modes, integer_values).each do |f, n, m, v, bm, im, iv|
        if c = columns_hash[f]
          case c.column.type
          when :string, :text
            search_sql = c.search_sql
            v = (v || '').downcase
            case m
            when "equals"
              if v.empty?
                where_clause = "(#{search_sql} LIKE ? ESCAPE '!' OR #{search_sql} IS NULL)"
              else
                where_clause = "#{search_sql} LIKE ? ESCAPE '!'"
              end
              tokens << v.gsub(/([_%!])/) { "!#{$1}" }
            when "contains"
              where_clause = "#{search_sql} LIKE ? ESCAPE '!'"
              tokens << "%#{v.gsub(/([_%!])/) { "!#{$1}" }}%"
            when "starts"
              where_clause = "#{search_sql} LIKE ? ESCAPE '!'"
              tokens << "#{v.gsub(/([_%!])/) { "!#{$1}" }}%"
            when "ends"
              where_clause = "#{search_sql} LIKE ? ESCAPE '!'"
              tokens << "%#{v.gsub(/([_%!])/) { "!#{$1}" }}"
            when "matches"
              where_clause = "#{search_sql} LIKE ?"
              tokens << v
            else
              raise "not yet #{m}"
            end
            if n == "not"
              where_clauses << "NOT(#{where_clause})"
            else
              where_clauses << where_clause
            end
          when :integer
            case im
            when "equals"
              where_clause = "#{c.search_sql} = #{iv.to_i}"
            when "lt"
              where_clause = "#{c.search_sql} < #{iv.to_i}"
            when "gt"
              where_clause = "#{c.search_sql} > #{iv.to_i}"
            when "le"
              where_clause = "#{c.search_sql} <= #{iv.to_i}"
            when "ge"
              where_clause = "#{c.search_sql} >= #{iv.to_i}"
            else
              raise "not yet #{im.inspect}"
            end
            if n == "not"
              where_clauses << "NOT(#{where_clause})"
            else
              where_clauses << where_clause
            end
          when :boolean
            case bm
            when "true"
              where_clauses << "#{c.search_sql} = 1"
            when "false"
              where_clauses << "#{c.search_sql} != 1"
            else
              raise "not yet #{bm.inspect}"
            end
          else
            raise "not yet #{c.column.type}"
          end
        end
      end
      
      [where_clauses.join(" AND "), *tokens]
    end

  end

end
