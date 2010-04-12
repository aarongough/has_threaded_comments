require File.dirname(__FILE__) + '/test_helper.rb' 

class ThreadedCommentTest < Test::Unit::TestCase 
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
  
  def test_schema_and_model_loaded
    assert_kind_of ThreadedComment, ThreadedComment.new
  end 
  
  def test_comment_should_be_created
    @expected_comment_count = ThreadedComment.count + 1
    assert ThreadedComment.new(@sample_comment).save, "Could not save comment"
    assert_equal @expected_comment_count, ThreadedComment.count
  end
    
  def test_comment_should_not_be_created_without_name
    @expected_comment_count = ThreadedComment.count
    assert_equal false, ThreadedComment.new(@sample_comment.merge({:name => nil})).save
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_comment_should_not_be_created_without_body
    @expected_comment_count = ThreadedComment.count
    assert_equal false, ThreadedComment.new(@sample_comment.merge({:body => nil})).save
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_comment_should_not_be_created_without_email
    @expected_comment_count = ThreadedComment.count
    assert_equal false, ThreadedComment.new(@sample_comment.merge({:email => nil})).save
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_comment_should_not_be_created_with_junk_email
    @expected_comment_count = ThreadedComment.count
    assert_equal false, ThreadedComment.new(@sample_comment.merge({:email => "asasdasdas"})).save
    assert_equal @expected_comment_count, ThreadedComment.count
  end
    
  def test_nested_comment
    @test_comment = ThreadedComment.new(@sample_comment)
    assert @test_comment.save
    @test_comment.reload
    @expected_comment_count = ThreadedComment.count(:conditions => ["threaded_comment_polymorphic_id = ? AND threaded_comment_polymorphic_type = ?", @test_comment.threaded_comment_polymorphic_id, @test_comment.threaded_comment_polymorphic_type]) + 1
    @test_subcomment = ThreadedComment.new(@sample_comment.merge({:parent_id => @test_comment.id, :threaded_comment_polymorphic_id => nil, :threaded_comment_polymorphic_type => nil}))
    assert @test_subcomment.save
    assert_equal @expected_comment_count, ThreadedComment.count(:conditions => ["threaded_comment_polymorphic_id = ? AND threaded_comment_polymorphic_type = ?", @test_comment.threaded_comment_polymorphic_id, @test_comment.threaded_comment_polymorphic_type]), "Nested comment was not correctly assigned it's parent's owner info"
  end
  
  def test_comment_with_no_parent_id_defaults_to_zero
    @expected_comment_count = ThreadedComment.count + 1
    @test_comment = ThreadedComment.new( @sample_comment )
    assert @test_comment.save, "Could not save comment"
    @test_comment.reload
    assert_equal 0, @test_comment.parent_id
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_comment_with_nil_parent_id_changes_to_zero
    @expected_comment_count = ThreadedComment.count + 1
    @test_comment = ThreadedComment.new( @sample_comment.merge({:parent_id => nil}) )
    assert @test_comment.save, "Could not save comment"
    @test_comment.reload
    assert_equal 0, @test_comment.parent_id
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_should_not_be_able_to_set_rating_via_mass_assignment
    @expected_comment_count = ThreadedComment.count + 1
    @test_comment = ThreadedComment.new( @sample_comment.merge({:rating => 20}) )
    @test_comment.save!
    @test_comment.reload
    assert_equal 0, @test_comment.rating
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_should_not_be_able_to_set_flags_via_mass_assignement
    @expected_comment_count = ThreadedComment.count + 1
    @test_comment = ThreadedComment.new( @sample_comment.merge({:flags => 20}) )
    @test_comment.save!
    @test_comment.reload
    assert_equal 0, @test_comment.flags
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_email_hash_creation
    @test_comment = ThreadedComment.new(@sample_comment)
    assert @test_comment.save
    assert_equal "#{@test_comment.email}-#{@test_comment.created_at}".hash.to_s(16), @test_comment.email_hash
  end
end 