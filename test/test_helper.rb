ENV['RAILS_ENV'] = 'test' 
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

load_path = File.join( File.dirname(__FILE__), "..", "generators", "install_has_threaded_comments", "templates", "threaded_comments_config.yml")
if( File.exists?(load_path))
  THREADED_COMMENTS_CONFIG = YAML.load_file(load_path)[RAILS_ENV]
end

require 'test_help'
require 'test/unit' 

def load_schema 
  config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'setup', 'database.yml')))  
  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))
  
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
  load(File.join(File.dirname(__FILE__), 'setup', 'schema.rb'))  
  require File.join(File.dirname(__FILE__), '..', 'rails', 'init.rb') 
end

load_schema

require 'factory_girl'

require File.join(File.dirname(__FILE__), 'setup', 'models.rb')
require File.join(File.dirname(__FILE__), 'setup', 'controllers.rb')
require File.join(File.dirname(__FILE__), 'setup', 'routes.rb')

require File.join(File.dirname(__FILE__), 'factories', 'book_factories.rb')
require File.join(File.dirname(__FILE__), 'factories', 'threaded_comment_factories.rb')