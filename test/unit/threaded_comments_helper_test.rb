require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsHelperTest < ActionView::TestCase

  include ThreadedCommentsHelper

  test "render_threaded_comments should render html" do
    comments = Factory(:threaded_comment)
    str = render_threaded_comments([comments])
    assert str.include?('this book rules')
  end
  
  # Stub out ActionView's AJAX helpers so we can test *our* helpers in isolation
  def link_to_remote(*args)
    "/threaded-comments/1"
  end

end
