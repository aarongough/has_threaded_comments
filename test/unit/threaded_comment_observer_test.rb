require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentObserverTest < ActiveSupport::TestCase
  
  include DelayedJobStubs
  
  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
    @test_parent_comment = @test_book.comments.create!(Factory.attributes_for(:threaded_comment))
  end
  
  test "should observe comment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      @test_book.comments.create(Factory.attributes_for(:threaded_comment))
    end
  end
  
  test "should observe comment creation and send delayed notifications" do
    stub_send_later do
      assert_difference("$delayed_jobs.length", 2) do
        @test_book.comments.create(Factory.attributes_for(:threaded_comment))
      end
    end
  end
  
  test "should observe subcomment creation and send notifications" do
    assert_difference("ActionMailer::Base.deliveries.length", 2) do
      @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :parent_id => @test_parent_comment.id))
    end
  end
  
  test "should observe subcomment creation and send delayed notifications" do
    stub_send_later do
      assert_difference("$delayed_jobs.length", 2) do
        @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :parent_id => @test_parent_comment.id))
      end
    end
  end
  
  test "should only send one notification after subcomment creation on comment with notifications = false" do
    @test_parent_comment.notifications = false
    @test_parent_comment.save
    assert_difference("ActionMailer::Base.deliveries.length", 1) do
      @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :parent_id => @test_parent_comment.id))
    end
  end
  
  test "should only send one delayed notification after subcomment creation on comment with notifications = false" do
    stub_send_later do
      @test_parent_comment.notifications = false
      @test_parent_comment.save
      assert_difference("$delayed_jobs.length", 1) do
        @test_book.comments.create!(Factory.attributes_for(:threaded_comment, :parent_id => @test_parent_comment.id))
      end
    end
  end
  
end
