require 'has_threaded_comments/extend_activerecord'

ActionView::Base.send :include, ThreadedCommentsHelper