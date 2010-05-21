ENV['RAILS_ENV'] = 'test' 
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

require 'test_help'
require 'test/unit'
require 'factory_girl'

require_files = []
require_files << File.join(File.dirname(__FILE__), '..', 'rails', 'init.rb')
require_files.concat Dir[File.join(File.dirname(__FILE__), 'factories', '*_factories.rb')]
require_files.concat Dir[File.join(File.dirname(__FILE__), 'setup', 'initialize_*.rb')]
require_files.concat Dir[File.join(File.dirname(__FILE__), 'stubs', '*_stubs.rb')]

require_files.each do |file|
  require File.expand_path(file)
end