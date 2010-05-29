ActionController::Base.send(:append_after_filter, Proc.new do |controller|
  cookies = controller.send(:cookies)
  cookies[:threaded_comment_cookies_enabled] = true
end)