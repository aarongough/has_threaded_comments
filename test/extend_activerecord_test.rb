require File.dirname(__FILE__) + '/test_helper.rb' 

class ExtendActiverecordTest < Test::Unit::TestCase 
  
  def setup
    @sample_book = @sample_article = {
      :title => "This is a test title",
      :content => "Wow! This item has some content!"
    }
    
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => 0, 
      :threaded_comment_polymorphic_type => 'Book'
    }
  end
  
  def test_schema_has_loaded_correctly 
    assert Book.new(@sample_book).save
    assert Article.new(@sample_article).save
  end
  
  def test_has_threaded_comments_association
    @test_book = Book.new(@sample_book)
    assert @test_book.save
    @test_book.comments.create(@sample_comment)
    assert_equal 1, @test_book.comments.count
  end
end 