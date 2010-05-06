ActionController::Routing::Routes.draw do |map|
  map.resources :threaded_comment, :only => [:new, :show, :create], :as => 'threaded-comments'
  map.flag_threaded_comment                   '/threaded-comments/:id/flag', :controller => 'threaded_comments', :action => 'flag', :conditions => { :method => :post }
  map.upmod_threaded_comment                  '/threaded-comments/:id/upmod', :controller => 'threaded_comments', :action => 'upmod', :conditions => { :method => :post }
  map.downmod_threaded_comment                '/threaded-comments/:id/downmod', :controller => 'threaded_comments', :action => 'downmod', :conditions => { :method => :post }
  map.remove_threaded_comment_notifications   '/threaded-comments/:id/remove-notifications/:hash', :controller => 'threaded_comments', :action => 'remove_notifications', :conditions => { :method => :get }
end