module ActiveScaffold::Config
  
  class AdvancedSearch < Base
    
    self.crud_type = :read
    
    def initialize(core_config)
      @core = core_config

      @full_text_search = self.class.full_text_search?
      @link = self.class.link.clone
    end

    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_advanced_search', :label => 'Advanced Search', :type => :table, :security_method => :advanced_search_authorized?)

    attr_accessor :link
    
    cattr_writer :full_text_search
    def self.full_text_search?
      @@full_text_search
    end
    @@full_text_search = true

    attr_writer :full_text_search
    def full_text_search?
      @full_text_search
    end

    def columns
      unless @columns
        self.columns = @core.columns.collect { |c| c.name if c.searchable? && c.column && (c.column.text? || (c.column.type == :integer) || (c.column.type == :boolean)) }.compact - [:id]
      end
      @columns
    end

    def columns=(val)
      @columns = ActiveScaffold::DataStructures::ActionColumns.new(*val)
      @columns.action = self
    end
    
    def column_objects
      @column_objects ||= @core.columns.select { |c| self.columns.include?(c.name) }
    end

  end

end
