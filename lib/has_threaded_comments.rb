require 'has_threaded_comments/extend_activerecord'
require File.join(File.dirname(__FILE__), "..", "config", "initializers", "load_config.rb")

ActionView::Base.send :include, ThreadedCommentsHelper