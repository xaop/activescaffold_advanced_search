module ActiveScaffold

  module AdvancedFinder

    def self.create_conditions_for_columns(columns, fields, negators, modes, values, boolean_modes, integer_modes, integer_values, group_boolean_modes)
      columns_hash = columns.inject({}) { |h, c| h[c.name.to_s] = c; h }

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
                    where_clause = "(UPPER(#{search_sql}) LIKE UPPER(?) ESCAPE '!' OR UPPER(#{search_sql}) IS NULL)"
                  else
                    where_clause = "UPPER(#{search_sql}) LIKE UPPER(?) ESCAPE '!'"
                  end
                  tokens << v.gsub(/([_%!])/) { "!#{$1}" }
                when "contains"
                  where_clause = "UPPER(#{search_sql}) LIKE UPPER(?) ESCAPE '!'"
                  tokens << "%#{v.gsub(/([_%!])/) { "!#{$1}" }}%"
                when "starts"
                  where_clause = "UPPER(#{search_sql}) LIKE UPPER(?) ESCAPE '!'"
                  tokens << "#{v.gsub(/([_%!])/) { "!#{$1}" }}%"
                when "ends"
                  where_clause = "UPPER(#{search_sql}) LIKE UPPER(?) ESCAPE '!'"
                  tokens << "%#{v.gsub(/([_%!])/) { "!#{$1}" }}"
                when "matches"
                  where_clause = "UPPER(#{search_sql}) LIKE UPPER(?)"
                  tokens << v
                else
                  raise "not yet #{m}"
              end
              if n == "not"
                if v.blank?
                  where_clauses << "NOT(#{where_clause})"
                else
                  where_clauses << "NOT(#{where_clause}) OR #{search_sql} IS NULL"
                end
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

      # [where_clauses.join(" AND "), *tokens]

      # group clauses by selected boolean attributes
      clause = "#{where_clauses[0]}"
      count = 1
      while count < group_boolean_modes.size
        clause += " #{group_boolean_modes[count]} #{where_clauses[count]}"
        count += 1
      end
      [clause, *tokens]

    end

  end

end
