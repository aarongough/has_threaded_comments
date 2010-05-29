require 'has_threaded_comments/extend_activerecord'
require 'has_threaded_comments/extend_actioncontroller'
require File.join(File.dirname(__FILE__), "..", "config", "initializers", "load_config.rb")

ThreadedCommentObserver.instance

ActionView::Base.send :include, ThreadedCommentsHelper