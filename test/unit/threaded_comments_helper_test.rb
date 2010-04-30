require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsHelperTest < ActionView::TestCase

  include ThreadedCommentsHelper
  include ActionViewStubs
  
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
  
  test "render_threaded_comments should escape comment names" do
    test_comment = Factory.build(:threaded_comment, :name => "<> Aaron")
    rendered_html = render_threaded_comments([test_comment])
    assert rendered_html.include?(h(test_comment.name)), "Did not escape comment name"
  end
  
  test "render_threaded_comments should output comment bodies" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(comment.body), "Did not include comment body"
    end
  end
  
  test "render_threaded_comments should escape comment bodies" do
    test_comment = Factory.build(:threaded_comment, :body => "<> Aaron")
    rendered_html = render_threaded_comments([test_comment])
    assert rendered_html.include?(h(test_comment.body)), "Did not escape comment body"
  end
  
  test "render_threaded_comments should output comment creation times" do
    @test_comments.each do |comment|
      assert @rendered_html.include?(time_ago_in_words(comment.created_at)), "Did not include comment creation time"
    end
  end
  
  test "render_threaded_comments should output anchor for each comment" do
    @test_comments.each do |comment|
      assert @rendered_html.include?("threaded_comment_#{comment.id}"), "Did not include anchor for comment"
    end
  end
  
  test "render_threaded_comments should output subcomment container for each comment" do
    @test_comments.each do |comment|
      assert @rendered_html.include?("subcomment_container_#{comment.id}"), "Did not include subcomment container for comment"
    end
  end
  
  test "render_threaded_comments options and config" do
    test_option "rating text", :enable_rating, "threaded_comment_rating_:id"
    test_option "upmod button", :enable_rating, link_to_remote('', :url => {:controller => "threaded_comments", :action => "upmod", :id => ":id"})
    test_option "downmod button", :enable_rating, link_to_remote('', :url => {:controller => "threaded_comments", :action => "downmod", :id => ":id"})
    test_option "flag button", :enable_flagging, link_to_remote('flag', :url => {:controller => "threaded_comments", :action => "flag", :id => ":id"})
    test_option "flag button container", :enable_flagging, "flag_threaded_comment_container_:id"
    test_option "reply link text", :reply_link_text, "Reply"
  end
  
  test "render_threaded_comments should not overwrite global config when options are set" do
    old_config = old_config = THREADED_COMMENTS_CONFIG.dup
    @rendered_html = render_threaded_comments(@test_comments, :enable_flagging => false)
    assert_equal old_config, THREADED_COMMENTS_CONFIG
  end
  
  test "should bucket comments for rendering" do
    test_comments = complex_thread(2)
    assert test_comments.first.is_a?(ThreadedComment)
    bucketed_comments = bucket_comments(test_comments)
    assert_not_equal bucketed_comments, test_comments
    assert_equal test_comments.last.id - 1, bucketed_comments.length, bucketed_comments.inspect
  end
  
  private
  
    def test_option(name, option_name, pattern, namespace = :render_threaded_comments)
      assert defined?(THREADED_COMMENTS_CONFIG[namespace][option_name]), "The option name '#{namespace}:#{option_name}' was not set in the default config"
      if(THREADED_COMMENTS_CONFIG[namespace][option_name].is_a?(TrueClass) or THREADED_COMMENTS_CONFIG[namespace][option_name].is_a?(FalseClass))
        # Enabled in config - not set in options
        change_config_option(namespace, option_name, true) do
          @rendered_html = render_threaded_comments(@test_comments)
          @test_comments.each do |comment|
            @single_comment = render_threaded_comments([comment])
            assert @rendered_html.include?(pattern.gsub(":id", comment.id.to_s)), "render_threaded_comments did not output '#{pattern.gsub(":id", comment.id.to_s)}' with '#{namespace}:#{option_name}' enabled in config\n ---------- \n#{@single_comment}\n"
          end
        end
        # Disabled in config - not set in options
        change_config_option(namespace, option_name, false) do
          @rendered_html = render_threaded_comments(@test_comments)
          @test_comments.each do |comment|
            @single_comment = render_threaded_comments([comment])
            assert !@rendered_html.include?(pattern.gsub(":id", comment.id.to_s)), "render_threaded_comments should not output '#{pattern.gsub(":id", comment.id.to_s)}' when '#{namespace}:#{option_name}' disabled in config\n ---------- \n#{@single_comment}\n"
          end
        end
        # Enabled in options - disabled in config - options should override
        change_config_option(namespace, option_name, false) do
          @rendered_html = render_threaded_comments(@test_comments, option_name => true)
          @test_comments.each do |comment|
            @single_comment = render_threaded_comments([comment], option_name => true)
            assert @rendered_html.include?(pattern.gsub(":id", comment.id.to_s)), "render_threaded_comments did not output '#{pattern.gsub(":id", comment.id.to_s)}' when '#{namespace}:#{option_name}' enabled in options\n ---------- \n#{@single_comment}\n"
          end
        end
        # Disabled in options - enabled in config - options should override
        change_config_option(namespace, option_name, true) do
          @rendered_html = render_threaded_comments(@test_comments, option_name => false)
          @test_comments.each do |comment|
            @single_comment = render_threaded_comments([comment], option_name => false)
            assert !@rendered_html.include?(pattern.gsub(":id", comment.id.to_s)), "render_threaded_comments should not output '#{pattern.gsub(":id", comment.id.to_s)}' when '#{namespace}:#{option_name}' disabled in options\n ---------- \n#{@single_comment}\n"
          end
        end
      elsif(THREADED_COMMENTS_CONFIG[namespace][option_name].is_a?(String))
        # Default - should be set in config
        @rendered_html = render_threaded_comments(@test_comments)
        @single_comment = render_threaded_comments([@test_comments[0]])
        assert_equal @test_comments.length, @rendered_html.split(pattern).length - 1, "render_threaded_comments did not output '#{pattern}' for each comment by default\n ---------- \n#{@single_comment}\n"
        # Set in config - not set in options
        change_config_option(namespace, option_name, "replacement_pattern_config") do
          @rendered_html = render_threaded_comments(@test_comments)
          @single_comment = render_threaded_comments([@test_comments[0]])
          assert_equal @test_comments.length, @rendered_html.split("replacement_pattern_config").length - 1, "render_threaded_comments did not output value of '#{namespace}:#{option_name}' for each comment when set in config\n ---------- \n#{@single_comment}\n"
          assert_equal 1, @rendered_html.split(pattern).length, "render_threaded_comments still output default value of '#{namespace}:#{option_name}' even when overwritten in config"
        end
        # Set in options - also set in config - options should override
        change_config_option(namespace, option_name, "replacement_pattern_config") do
          @rendered_html = render_threaded_comments(@test_comments, option_name => "replacement_pattern_options")
          @single_comment = render_threaded_comments([@test_comments[0]], option_name => "replacement_pattern_options")
          assert_equal @test_comments.length, @rendered_html.split("replacement_pattern_options").length - 1, "render_threaded_comments did not output value of '#{namespace}:#{option_name}' for each comment when set in options\n ---------- \n#{@single_comment}\n"
          assert_equal 1, @rendered_html.split(pattern).length, "render_threaded_comments still output default value of '#{namespace}:#{option_name}' even when overwritten in config and options"
          assert_equal 1, @rendered_html.split("replacement_pattern_config").length, "render_threaded_comments still output config value of '#{namespace}:#{option_name}' even when overwritten in options"
        end
      else
        flunk "Unrecognized option type: #{THREADED_COMMENTS_CONFIG[namespace][option_name].class}"
      end
    end
  
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
    
    def change_config_option(namespace, key, value, &block)
      old_config = THREADED_COMMENTS_CONFIG.dup
      old_stderr = $stderr
      $stderr = StringIO.new
      THREADED_COMMENTS_CONFIG[namespace][key] = value
      $stderr = old_stderr
      yield block
    ensure
      $stderr = StringIO.new
      Kernel.const_set('THREADED_COMMENTS_CONFIG', old_config)
      $stderr = old_stderr
    end

end
