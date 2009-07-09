## Activescaffold Advanced Search Plugin

Enables you search on specific fields:

* search on string, text, integer and boolean columns
* only "AND" conditions...

    
    

#### Usage

Add the following to your application.rb (or application_controller.rb for rails > 2.3)

    ActiveScaffold.set_defaults do |conf|
      conf.actions.exclude :search
      conf.actions.add :advanced_search
    end


This will activate the advanced search plugin for all your controllers.

Ofcourse, you can also do this only for a specific controller.

    
    

#### TODO

* search on date columns
* grouping of conditions (AND / OR)

    
    
#### WARNING: Does not work with Prototype 1.5.0 due to an error in how it serializes forms. Has been tested with 1.6.0.2.