require File.dirname(__FILE__) + '/test_helper.rb' 

class ThreadedCommentObserverTest < ActiveSupport::TestCase
  load_schema
  
  def setup
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => 1, 
      :threaded_comment_polymorphic_type => 'Book'
    }
  end
  
  test "should observe comment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      ThreadedComment.create!( @sample_comment )
    end
  end
  
  test "should observe subcomment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      ThreadedComment.create!( @sample_comment )
    end
  end
  
  test "should only send one notification after subcomment creation on comment with notifications = false" do
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      ThreadedComment.create!( @sample_comment )
    end
  end
  
end
