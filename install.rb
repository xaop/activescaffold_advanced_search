# Work around a problem with script/plugin and http-based repos.
# See http://dev.rubyonrails.org/ticket/8189
Dir.chdir(Dir.getwd.sub(/vendor.*/, '')) do

  ##
  ## Copy over asset files (javascript/css/images) from the plugin directory to public/
  ##

  def copy_files(source_path, destination_path, directory)
    source, destination = File.join(directory, source_path), File.join(RAILS_ROOT, destination_path)
    FileUtils.mkdir(destination) unless File.exist?(destination)
    FileUtils.cp_r(Dir.glob(source + '/*.*'), destination)
  end

  directory = File.dirname(__FILE__)

  copy_files("/public", "/public", directory)

  available_frontends = Dir[File.join(directory, 'frontends', '*')].collect { |d| File.basename d }
  [:stylesheets, :javascripts, :images].each do |asset_type|
    path = "/public/#{asset_type}/active_scaffold"
    copy_files(path, path, directory)

    available_frontends.each do |frontend|
      source = "/frontends/#{frontend}/#{asset_type}/"
      destination = "/public/#{asset_type}/active_scaffold/#{frontend}"
      copy_files(source, destination, directory)
    end
  end

end

def create_model
  # Install model
  if Dir["db/migrate/*_create_saved_advanced_searches.rb"].empty?
    system "script/generate model SavedAdvancedSearch name:string model_name:string query:text valid:boolean"
  
    system "rake db:migrate"
  else
    # In this case the model was already generated in the database, since we are
    # unable to drop the table in the database in a reliable manner we have to assume it still exists
    # so we do not create a migration, and we do not migrate
    system "script/generate model --skip-migration SavedAdvancedSearch name:string model_name:string query:text valid:boolean"
  end
  
  puts "Model SavedAdvancedSearch should exist"
end

puts "Creating model"
create_model
