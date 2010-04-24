require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class ThreadedCommentNotifierTest < ActionMailer::TestCase

  def setup
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => 0, 
      :threaded_comment_polymorphic_type => 'Book'
    }
    
    ThreadedComment.create!( @sample_comment )
  end
  
  test "should send new comment notification" do
    comment = ThreadedComment.find(1)
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_new_comment_notification( comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG["admin_email"]], @email.to
    assert_equal [THREADED_COMMENTS_CONFIG["system_send_email_address"]], @email.from
    assert @email.subject.index( "New" ), "Email subject did not include 'New'"
    assert @email.body.index( comment.body ), "Email did not include comment body"
    assert @email.body.index( comment.name ), "Email did not include comment name"
    assert @email.body.index( comment.email ), "Email did not include comment email address"
  end
  
  test "should send user comment reply notification" do
    comment = ThreadedComment.find(1)
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_comment_reply_notification( 'test@test.com', comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG["system_send_email_address"]], @email.from
    assert @email.body.index( comment.body ), "Email did not include comment body"
    assert @email.body.index( comment.name ), "Email did not include comment name"
    assert_nil @email.body.index( comment.email ), "Email should not include comment email address"
  end
  
  test "should send failed comment notification" do
    comment = ThreadedComment.find(1)
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_failed_comment_creation_notification( comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG["admin_email"]], @email.to
    assert_equal [THREADED_COMMENTS_CONFIG["system_send_email_address"]], @email.from
    assert @email.subject.index( "Failed" ), "Email subject did not include 'Failed'"
    assert @email.body.index( comment.body ), "Email did not include comment body"
    assert @email.body.index( comment.name ), "Email did not include comment name"
    assert @email.body.index( comment.email ), "Email did not include comment email address"
  end
  
end
