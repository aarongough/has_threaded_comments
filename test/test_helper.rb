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
  config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'fixtures', 'database.yml')))  
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
  load(File.join(File.dirname(__FILE__), 'fixtures', 'schema.rb'))  
  require File.join(File.dirname(__FILE__), '..', 'rails', 'init.rb') 
end

load_schema

class Book < ActiveRecord::Base 
  has_threaded_comments
end 

class Article < ActiveRecord::Base 
  has_threaded_comments
end

Book.create()
Article.create()

ActionController::Routing::Routes.draw do |map| 
  map.resources :books, :articles
end 