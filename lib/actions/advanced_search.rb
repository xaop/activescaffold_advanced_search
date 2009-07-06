module ActiveScaffold::Actions
  
  module AdvancedSearch
    
    def self.included(base)
      base.before_filter :advanced_search_authorized?, :only => :show_advanced_search
      base.before_filter :do_advanced_search
    end

    def show_advanced_search
      options = active_scaffold_config.advanced_search.columns.map { |c| "<option value='#{c.name}'>#{c.label}</option>" }.join
      type_map = "{" + active_scaffold_config.advanced_search.column_objects.map do |c|
        "#{c.name.to_s.inspect}: #{(c.column.text? ? "'text'" : c.column.type == :integer ? "'integer'" : "'boolean'")}"
      end.join(', ') + "}"
      respond_to do |type|
        type.html { render(:partial => "advanced_search", :layout => false, :locals => { :options => options, :type_map => type_map }) }
        type.js { render(:partial => "advanced_search", :layout => false, :locals => { :options => options, :type_map => type_map }) }
      end
    end

    protected
    
    def do_advanced_search
      @query = params[:advanced_search].to_s.strip rescue ''
      fields = Array(params[:as_field] || [])
      negators = Array(params[:as_negator] || [])
      modes = Array(params[:as_matcher] || [])
      values = Array(params[:as_search] || [])
      boolean_modes = Array(params[:as_b_matcher] || [])
      integer_modes = Array(params[:as_i_matcher] || [])
      integer_values = Array(params[:as_i_search] || [])
      
      unless @query.empty? && (fields.empty? || modes.empty? || values.empty?)
        columns = active_scaffold_config.advanced_search.columns
        like_pattern = active_scaffold_config.advanced_search.full_text_search? ? '%?%' : '?%'
        conds = self.active_scaffold_conditions
        conds = merge_conditions(conds, ActiveScaffold::Finder.create_conditions_for_columns(@query.split(' '), columns, like_pattern)) unless @query.empty?
        conds = merge_conditions(conds, ActiveScaffold::AdvancedFinder.create_conditions_for_columns(columns, fields, negators, modes, values, boolean_modes, integer_modes, integer_values))
        self.active_scaffold_conditions = conds
        includes_for_search_columns = columns.collect{ |column| column.includes }.flatten.uniq.compact
        self.active_scaffold_joins.concat includes_for_search_columns
      
        active_scaffold_config.list.user.page = nil
      end
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def advanced_search_authorized?
      authorized_for?(:action => :read)
    end

  end

end
