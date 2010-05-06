require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))
require 'digest/md5'

class ThreadedCommentTest < ActiveSupport::TestCase 
  
  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
  end
  
  test "threaded comment should be created" do
    assert_difference('ThreadedComment.count') do
      ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
    end
  end
  
  test "threaded comment should not be created without name" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(Factory.attributes_for(:threaded_comment, :name => nil))
    end
  end
  
  test "threaded comment should not be create without body" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(Factory.attributes_for(:threaded_comment, :body => nil))
    end
  end
  
  test "threaded comment should not be created without email" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(Factory.attributes_for(:threaded_comment, :email => nil))
    end
  end
  
  test "threaded comment should not be created with junk email" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(Factory.attributes_for(:threaded_comment, :email => "asasdasdas"))
    end
  end
    
  test "threaded sub-comment should be created and associated with it's correct parent" do
    assert_difference('ThreadedComment.count', 2) do
      @test_comment = @test_book.comments.create!(Factory.attributes_for(:threaded_comment))
      @test_subcomment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment, :parent_id => @test_comment.id, :threaded_comment_polymorphic_id => nil, :threaded_comment_polymorphic_type => nil))
      @test_subcomment.reload
      assert_equal @test_comment.threaded_comment_polymorphic_id, @test_subcomment.threaded_comment_polymorphic_id
      assert_equal @test_comment.threaded_comment_polymorphic_type, @test_subcomment.threaded_comment_polymorphic_type
    end
  end
  
  test "threaded comment with nil parent_id defaults to zero" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
      @test_comment.reload
      assert_equal 0, @test_comment.parent_id
    end
  end
  
  test "threaded comment with empty parent_id defaults to zero" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment, :parent_id => ""))
      @test_comment.reload
      assert_equal 0, @test_comment.parent_id
    end
  end
  
  test "threaded comment rating should not be able to be set via mass assignment" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment, :rating => 20))
      @test_comment.reload
      assert_equal 0, @test_comment.rating
    end
  end
  
  test "threaded comment flags should not be able to be set via mass assignment" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment, :flags => 20))
      @test_comment.reload
      assert_equal 0, @test_comment.flags
    end
  end
  
  test "threaded comment email hash creation" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
      assert_equal Digest::MD5.hexdigest("#{@test_comment.email}-#{@test_comment.created_at}"), @test_comment.email_hash
    end
  end
  
  test "owner_item should alias threaded_comment_polymorphic" do
    @test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
    assert_equal @test_comment.owner_item, @test_comment.threaded_comment_polymorphic
  end
end 