require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentNotifierTest < ActionMailer::TestCase

  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
    @test_comment = @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :threaded_comment_polymorphic_id => nil, :threaded_comment_polymorphic_type => nil))
  end
  
  test "should send new comment notification" do
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_new_comment_notification( @test_comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:admin_email]], @email.to
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]], @email.from
    assert @email.subject.index( "New" ), "Email subject did not include 'New':\n#{@email.subject}"
    assert @email.body.index( @test_comment.body ), "Email did not include comment body:\n#{@email.body}"
    assert @email.body.index( @test_comment.name ), "Email did not include comment name:\n#{@email.body}"
    assert @email.body.index( @test_comment.email ), "Email did not include comment email address:\n#{@email.body}"
    assert @email.body.index( THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/books/#{@test_comment.owner_item.id}#threaded_comment_" + @test_comment.id.to_s ), "Email did not include link to comment:\n#{@email.body}"
  end
  
  test "should send user comment reply notification" do
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_comment_reply_notification( 'test@test.com', @test_comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]], @email.from
    assert @email.body.index( @test_comment.body ), "Email did not include comment body:\n#{@email.body}"
    assert @email.body.index( @test_comment.name ), "Email did not include comment name:\n#{@email.body}"
    assert_nil @email.body.index( @test_comment.email ), "Email should not include comment email address:\n#{@email.body}"
    assert @email.body.index( THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/books/#{@test_comment.owner_item.id}\n" ), "Email did not include link to comment parent item:\n#{@email.body}"
    assert @email.body.index( THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/books/#{@test_comment.owner_item.id}#threaded_comment_" + @test_comment.id.to_s ), "Email did not include link to comment:\n#{@email.body}"
  end
  
  test "should send user subcomment reply notification" do
    @test_subcomment = @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :threaded_comment_polymorphic_id => nil, :threaded_comment_polymorphic_type => nil, :parent_id => @test_comment.id))
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_comment_reply_notification( @test_comment.email, @test_subcomment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]], @email.from
    assert @email.body.index( @test_subcomment.body ), "Email did not include comment body:\n#{@email.body}"
    assert @email.body.index( @test_subcomment.name ), "Email did not include comment name:\n#{@email.body}"
    assert_nil @email.body.index( @test_subcomment.email ), "Email should not include comment email address:\n#{@email.body}"
    assert @email.body.index( THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/books/#{@test_subcomment.owner_item.id}\n" ), "Email did not include link to comment parent item:\n#{@email.body}"
    assert @email.body.index( THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/books/#{@test_subcomment.owner_item.id}#threaded_comment_" + @test_subcomment.id.to_s ), "Email did not include link to comment:\n#{@email.body}"
    removal_link = THREADED_COMMENTS_CONFIG[:notifications][:site_domain] + "/threaded-comments/#{@test_comment.id}/remove-notifications/#{@test_comment.email_hash}"
    assert @email.body.index(removal_link), "Email did not include notification removal link:\n\n#{removal_link}\n\n#{@email.body}"
  end
  
  test "should send failed comment notification" do
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @email = ThreadedCommentNotifier.deliver_failed_comment_creation_notification( @test_comment )
    end
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:admin_email]], @email.to
    assert_equal [THREADED_COMMENTS_CONFIG[:notifications][:system_send_email_address]], @email.from
    assert @email.subject.index( "Failed" ), "Email subject did not include 'Failed'"
    assert @email.body.index( @test_comment.body ), "Email did not include comment body"
    assert @email.body.index( @test_comment.name ), "Email did not include comment name"
    assert @email.body.index( @test_comment.email ), "Email did not include comment email address"
  end
  
end
