require File.dirname(__FILE__) + '/test_helper.rb' 

class HasThreadedCommentsTest < Test::Unit::TestCase
  
  def test_schema_has_loaded_correctly 
    assert Book.new(@sample_book).save
    assert Article.new(@sample_article).save
  end
  
end 