require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsHelperTest < ActionView::TestCase

  include ThreadedCommentsHelper
  
  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
  end

  test "render_threaded_comments should render html" do
    comment = Factory(:threaded_comment)
    str = render_threaded_comments([comment])
    assert str.include?(comment.body)
  end
  
  # Stub out ActionView's AJAX helpers so we can test *our* helpers in isolation
  def link_to_remote(*args)
    "/threaded-comments/1"
  end

end
