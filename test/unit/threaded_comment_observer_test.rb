require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class ThreadedCommentObserverTest < ActiveSupport::TestCase
  
  def setup
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => 0, 
      :threaded_comment_polymorphic_type => 'Book'
    }
  end
  
  test "should observe comment creation and send notifications" do
    @test_book = Book.new( :title => 'blah', :content => 'blah', :email => 'test@example.com' )
    @test_book.save
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      ThreadedComment.create!( @sample_comment.merge({:threaded_comment_polymorphic_id => @test_book.id}) )
    end
  end
  
  test "should observe subcomment creation and send notifications" do
    @test_comment = ThreadedComment.new(@sample_comment)
    @test_comment.save
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      ThreadedComment.create!( @sample_comment.merge({:parent_id => @test_comment.id}) )
    end
  end
  
  test "should only send one notification after subcomment creation on comment with notifications = false" do
    @no_notifications = ThreadedComment.new(@sample_comment)
    @no_notifications.notifications = false
    @no_notifications.save
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      ThreadedComment.create!( @sample_comment.merge({:parent_id => @no_notifications.id}) )
    end
  end
  
end
