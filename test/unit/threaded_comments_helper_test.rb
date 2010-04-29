require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsHelperTest < ActionView::TestCase

  include ThreadedCommentsHelper
  
  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
    @test_comments = complex_thread(2)
    @rendered_html = render_threaded_comments(@test_comments)
  end

  test "render_threaded_comments should output comment names" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(comment.name), "Did not include comment name"
    end
  end
  
  test "render_threaded_comments should output comment bodies" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(comment.body), "Did not include comment body"
    end
  end
  
  test "render_threaded_comments should output comment creation times" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(time_ago_in_words(comment.created_at)), "Did not include comment creation time"
    end
  end
  
  test "render_threaded_comments should output comment rating & buttons by default" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(comment.rating.to_s), "Did not include comment rating"
      assert @rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id})), "Did not include comment upmod button"
      assert @rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id})), "Did not include comment downmod button"
    end
  end
  
  test "render_threaded_comments should output comment rating & buttons if 'rating' is set in option, even if disabled in config" do
    change_config_option("rating", false) do
      @rendered_html = render_threaded_comments(@test_comments, :rating => true)
      @test_comments.each do |comment|
        assert @rendered_html.include?(comment.rating.to_s), "Did not include comment rating"
        assert @rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id})), "Did not include comment upmod button"
        assert @rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id})), "Did not include comment downmod button"
      end
    end
  end
  
  test "render_threaded_comments should not output comment ratings & buttons if 'rating' disabled in options" do
    @rendered_html = render_threaded_comments(@test_comments, :rating => false)
    @test_comments.each do |comment|
      assert !@rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id})), "Should not include comment downmod button"
      assert !@rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id})), "Should not include comment upmod button"
      assert !@rendered_html.include?("threaded_comment_rating_#{comment.id}"), "Should not include comment rating"
    end
  end
  
  
  test "render_threaded_comments should not output comment ratings & buttons if 'rating' disabled in config" do
    change_config_option("rating", false) do
      @test_comments.each do |comment|
        assert !@rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'downmod', :id => comment.id})), "Should not include comment downmod button"
        assert !@rendered_html.include?(link_to_remote('',:url => {:controller => 'threaded_comments', :action => 'upmod', :id => comment.id})), "Should not include comment upmod button"
        assert !@rendered_html.include?("threaded_comment_rating_#{comment.id}"), "Should not include comment rating"
      end
    end
  end
  
  test "render_threaded_comments should output comment flag button by default" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(link_to_remote('flag',:url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id})), "Did not include comment flag button"
    end
  end
  
  test "render_threaded_comments should output comment flag button if 'flagging' set in options, even if disabled in config" do
    change_config_option("flagging", false) do
      @rendered_html = render_threaded_comments(@test_comments, :flagging => true)
      @test_comments.each do |comment|
        assert @rendered_html.include?(link_to_remote('flag',:url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id})), "Did not include comment flag button"
      end
    end
  end
  
  test "render_threaded_comments should not output comment flag button if 'flagging' disabled in options" do
    @rendered_html = render_threaded_comments(@test_comments, :flagging => false)
    @test_comments.each do |comment|
      assert !@rendered_html.include?(link_to_remote('flag',:url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id})), "Should not include comment flag button"
    end
  end
  
  test "render_threaded_comments should not output comment flag button if 'flagging' disabled in config" do
    change_config_option("flagging", false) do
      @test_comments.each do |comment|
        assert !@rendered_html.include?(link_to_remote('flag',:url => {:controller => 'threaded_comments', :action => 'flag', :id => comment.id})), "Should not include comment flag button"
      end
    end
  end
  
  test "render_threaded_comments should output anchors for each comment" do
    @test_comments.each do |comment|
      assert @rendered_html.include?("#threaded_comment_#{comment.id}"), "Did not include comment anchor"
    end
  end
  
  test "render_threaded_comments should output reply link for each comment" do
    assert_equal @test_comments.length, @rendered_html.split("/threaded_comments/new").length - 1
  end
  
  # Stub out some of ActionView's helpers so we can test *our* helpers in isolation
  def link_to_remote(*args)
    if( args.last.is_a?(Hash))
      url = args.last[:url]
      url = "/#{url[:controller]}/#{url[:action]}/#{url[:id]}"
    end
    if( args.first.is_a?(String))
      "<a href=\"#{url}\">#{args.first}</a>"
    else
      ""
    end
  end
  
  def time_ago_in_words(*args)
    "30 minutes ago"
  end
  
  private
  
    def complex_thread(length=100)
      comments = []
      length.times do
        comments << parent_comment = Factory.build(:threaded_comment)
        3.times do
          comments << subcomment1 = Factory.build(:threaded_comment, :parent_id => parent_comment.id)
          2.times do
            comments << subcomment2 = Factory.build(:threaded_comment, :parent_id => subcomment1.id)
            2.times do
              comments << subcomment3 = Factory.build(:threaded_comment, :parent_id => subcomment2.id)
            end
          end
        end
      end
      comments
    end
    
    def change_config_option(key, value, &block)
      old_config = THREADED_COMMENTS_CONFIG.dup
      old_stderr = $stderr
      $stderr = StringIO.new
      THREADED_COMMENTS_CONFIG[key] = value
      $stderr = old_stderr
      @rendered_html = render_threaded_comments(@test_comments)
      yield block
    ensure
      $stderr = StringIO.new
      Kernel.const_set('THREADED_COMMENTS_CONFIG', old_config)
      $stderr = old_stderr
    end

end
