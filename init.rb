# Make sure that ActiveScaffold has already been included
ActiveScaffold rescue throw "should have included ActiveScaffold plug in first.  Please make sure that this plug-in comes alphabetically after the ActiveScaffold plug-in"

Kernel.load 'actions/advanced_search.rb'
Kernel.load 'config/advanced_search.rb'
Kernel.load 'helpers/view_helpers.rb'
Kernel.load 'helpers/advanced_search_helpers.rb'
Kernel.load 'advanced_finder.rb'

##
## Run the install script, too, just to make sure
## But at least rescue the action in production
##
#** DISABLED: this does not work when generating a model in install.rb, because this causes a loop
#begin
#  Kernel::load(File.join(File.dirname(__FILE__), 'install.rb'))
#rescue
#  raise $! unless RAILS_ENV == 'production'
#end

# Register our helper methods
ActionView::Base.send(:include, ActiveScaffold::Helpers::AdvancedSearchHelpers)
