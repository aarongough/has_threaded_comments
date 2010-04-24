require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class ThreadedCommentTest < ActiveSupport::TestCase 
  
  def setup
    @sample_book = {
      :title => "This is a test title",
      :content => "Wow! This item has some content!"
    }
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com",
      :threaded_comment_polymorphic_id => 1, 
      :threaded_comment_polymorphic_type => 'Book'
    }
    @test_book = Book.create!(@sample_book)
  end
  
  test "threaded comment should be created" do
    assert_difference('ThreadedComment.count') do
      ThreadedComment.create(@sample_comment)
    end
  end
  
  test "threaded comment should not be created without name" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(@sample_comment.merge({:name => nil}))
    end
  end
  
  test "threaded comment should not be create without body" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(@sample_comment.merge({:body => nil}))
    end
  end
  
  test "threaded comment should not be created without email" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(@sample_comment.merge({:email => nil}))
    end
  end
  
  test "threaded comment should not be created with junk email" do
    assert_no_difference('ThreadedComment.count') do
      ThreadedComment.create(@sample_comment.merge({:email => "asasdasdas"}))
    end
  end
    
  test "threaded sub-comment should be created and associated with it's correct parent" do
    assert_difference('ThreadedComment.count', 2) do
      @test_comment = @test_book.comments.create(@sample_comment)
      @test_subcomment = ThreadedComment.create(@sample_comment.merge({:parent_id => @test_comment.id, :threaded_comment_polymorphic_id => nil, :threaded_comment_polymorphic_type => nil}))
      @test_subcomment.reload
      assert_equal @test_comment.threaded_comment_polymorphic_id, @test_subcomment.threaded_comment_polymorphic_id
      assert_equal @test_comment.threaded_comment_polymorphic_type, @test_subcomment.threaded_comment_polymorphic_type
    end
  end
  
  test "threaded comment with nil parent_id defaults to zero" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create( @sample_comment )
      @test_comment.reload
      assert_equal 0, @test_comment.parent_id
    end
  end
  
  test "threaded comment with empty parent_id defaults to zero" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create( @sample_comment.merge({:parent_id => ""}) )
      @test_comment.reload
      assert_equal 0, @test_comment.parent_id
    end
  end
  
  test "threaded comment rating should not be able to be set via mass assignment" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create( @sample_comment.merge({:rating => 20}) )
      @test_comment.reload
      assert_equal 0, @test_comment.rating
    end
  end
  
  test "threaded comment flags should not be able to be set via mass assignment" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create( @sample_comment.merge({:flags => 20}) )
      @test_comment.reload
      assert_equal 0, @test_comment.flags
    end
  end
  
  test "threaded comment email hash creation" do
    assert_difference('ThreadedComment.count') do
      @test_comment = ThreadedComment.create(@sample_comment)
      assert_equal "#{@test_comment.email}-#{@test_comment.created_at}".hash.to_s(16), @test_comment.email_hash
    end
  end
  
  test "owner_item should alias threaded_comment_polymorphic" do
    @test_comment = ThreadedComment.create(@sample_comment)
    assert_equal @test_comment.owner_item, @test_comment.threaded_comment_polymorphic
  end
end 