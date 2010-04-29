require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ExtendActiverecordTest < ActiveSupport::TestCase 
  
  test "book schema and model has loaded correctly" do
    assert_difference('Book.count') do
      assert Book.new(Factory.attributes_for(:book)).save
    end
  end
  
  test "has_threaded_comments association" do
    @test_book = Book.create!(Factory.attributes_for(:book))
    assert_difference('ThreadedComment.count') do
      assert_difference('@test_book.comments.count') do 
        @test_book.comments.create(Factory.attributes_for(:threaded_comment))
      end
    end
  end
  
end 