require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ConfigLoaderTest < ActiveSupport::TestCase
  
  test "should loaded threaded_comments_config.yml" do
    assert_not_nil THREADED_COMMENTS_CONFIG
    assert_not_nil THREADED_COMMENTS_CONFIG[:notifications]
    assert_not_nil THREADED_COMMENTS_CONFIG[:render_threaded_comments]
    assert_not_nil THREADED_COMMENTS_CONFIG[:render_comment_form]
  end
  
end