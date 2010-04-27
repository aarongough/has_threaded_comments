ActionController::Routing::Routes.draw do |map| 
  map.resources           :books
  map.threaded_comments   '/threaded-comments', :controller => 'threaded_comments', :action => 'index', :conditions => { :method => :get }
end 