module ActiveScaffold::Config

  class Core

    cattr_accessor :advanced_search_plugin_directory
    @@advanced_search_plugin_directory = File.expand_path(__FILE__).match(/vendor\/plugins\/([^\/]*)/)[1]
    
    def template_search_path_with_advanced_search(frontend = self.frontend)
      frontends_path = "../../vendor/plugins/#{ActiveScaffold::Config::Core.advanced_search_plugin_directory}/frontends"
    
      search_path = template_search_path_without_advanced_search
      search_path << "#{frontends_path}/#{frontend}/views" if frontend.to_sym != :default
      search_path << "#{frontends_path}/default/views"
      return search_path
    end
    
    ActionController::Resources::Resource::ACTIVE_SCAFFOLD_ROUTING[:collection][:show_advanced_search] = :get
    
    alias_method_chain :template_search_path, :advanced_search

  end
  
end
