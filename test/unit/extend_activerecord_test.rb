require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')

class ExtendActiverecordTest < ActiveSupport::TestCase 
  
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
  end
  
  test "book schema and model has loaded correctly" do
    assert_difference('Book.count') do
      assert Book.new(@sample_book).save
    end
  end
  
  test "has_threaded_comments association" do
    @test_book = Book.new(@sample_book)
    assert @test_book.save
    assert_difference('ThreadedComment.count') do
      assert_difference('@test_book.comments.count') do 
        @test_book.comments.create(@sample_comment)
      end
    end
  end
  
end 