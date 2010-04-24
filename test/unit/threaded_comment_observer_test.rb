require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class ThreadedCommentObserverTest < ActiveSupport::TestCase
  
  def setup
    @sample_book = {
      :title => "This is a test title",
      :content => "Wow! This item has some content!"
    }
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com"
    }
    @test_book = Book.create!(@sample_book)
    @test_parent_comment = @test_book.comments.create!(@sample_comment)
  end
  
  test "should observe comment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      @test_book.comments.create(@sample_comment)
    end
  end
  
  test "should observe subcomment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      @test_book.comments.create!(@sample_comment.merge({:parent_id => @test_parent_comment.id}))
    end
  end
  
  test "should only send one notification after subcomment creation on comment with notifications = false" do
    @test_parent_comment.notifications = false
    @test_parent_comment.save
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @test_book.comments.create!(@sample_comment.merge({:parent_id => @test_parent_comment.id}))
    end
  end
  
end
