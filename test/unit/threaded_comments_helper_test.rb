require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')



class ThreadedCommentsHelperTest < ActionView::TestCase

  include ActionView::Helpers
  include ActionController::Helpers
  include ActionController::RequestForgeryProtection
  include ApplicationHelper

  def protect_against_forgery?
    false
  end

  include ThreadedCommentsHelper

  test "render_threaded_comments should render html" do
    comments = Factory(:threaded_comment)
    str = render_threaded_comments([comments])
    assert str.include?('this book rules')
  end

end
