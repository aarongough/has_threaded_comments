config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'config', 'database.yml')))  
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), '..','debug.log'))

db_adapter = ENV['DB'] 

# no db passed, try one of these fine config-free DBs before bombing.  
db_adapter ||= 
  begin 
    require 'rubygems'  
    require 'sqlite'  
    'sqlite'  
  rescue MissingSourceFile
    begin 
      require 'sqlite3'
      'sqlite3'  
    rescue MissingSourceFile 
    end  
  end  

if db_adapter.nil? 
  raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."  
end  

ActiveRecord::Base.establish_connection(config[db_adapter])  
load(File.join(File.dirname(__FILE__), 'config', 'schema.rb'))  