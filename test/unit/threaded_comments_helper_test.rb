require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsHelperTest < ActionView::TestCase

  include ThreadedCommentsHelper
  include ActionViewStubs
  
  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
    @test_comments = create_complex_thread(2)
    @test_comment = Factory.build(:threaded_comment)
    @rendered_html = render_threaded_comments(@test_comments)
  end
  
  test "render_threaded_comments should output no_comments_message when comments.length = 0" do
    @rendered_html = render_threaded_comments([])
    assert @rendered_html.include?(THREADED_COMMENTS_CONFIG[:render_threaded_comments][:no_comments_message]), "The 'no comments' message was not included"
    assert @rendered_html.include?('id="no_comments_message"'), "The no_comments_message container was not included"
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
  
  test "render_threaded_comments should not mark comments with more than max_indent ancestors as indented" do
    10.times do |max_indent|
      @rendered_html = render_threaded_comments(@test_comments, :max_indent => max_indent)
      @test_comments.each do |comment|
        ancestors = 0
        if(comment.parent_id > 0)
          parent_comment = @test_comments[comment.parent_id - @test_comments.first.id]
          ancestors += 1
          assert_equal comment.parent_id, parent_comment.id
          until(parent_comment.parent_id == 0) do
            parent_comment = @test_comments[parent_comment.parent_id - @test_comments.first.id]
            ancestors += 1
          end
        end
        subcomment_container_position = @rendered_html.index("subcomment_container_#{comment.id}")
        assert_not_nil subcomment_container_position
        @subcomment_html = @rendered_html.slice(subcomment_container_position - 100, 200)
        assert @subcomment_html.include?('class="subcomment_container"'), "Expecting 'class=\"subcomment_container\"':\n" + @subcomment_html if(ancestors < max_indent)
        assert @subcomment_html.include?('class="subcomment_container_no_indent"'), "Expecting 'class=\"subcomment_container_no_indent\"':\n" + @subcomment_html if(ancestors >= max_indent)
      end
    end
  end
  
  test "render_threaded_comments should not mark comments with a rating of 5 with fade_level" do
    test_comment = Factory.build(:threaded_comment, :rating => 5)
    @rendered_html = render_threaded_comments([test_comment])
    assert !@rendered_html.include?("fade_level"), "Comment should not be marked with fade level"
  end
  
  test "render_threaded_comments should not mark comments with a rating of 0 with fade_level" do
    test_comment = Factory.build(:threaded_comment, :rating => 0)
    @rendered_html = render_threaded_comments([test_comment])
    assert !@rendered_html.include?("fade_level"), "Comment should not be marked with fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -1 with fade_level_1" do
    test_comment = Factory.build(:threaded_comment, :rating => -1)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_1"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -2 with fade_level_2" do
    test_comment = Factory.build(:threaded_comment, :rating => -2)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_2"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -3 with fade_level_3" do
    test_comment = Factory.build(:threaded_comment, :rating => -3)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_3"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -4 with fade_level_4" do
    test_comment = Factory.build(:threaded_comment, :rating => -4)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_4"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -5 with fade_level_4" do
    test_comment = Factory.build(:threaded_comment, :rating => -5)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_4"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments should mark comments with a rating of -10 with fade_level_4" do
    test_comment = Factory.build(:threaded_comment, :rating => -10)
    @rendered_html = render_threaded_comments([test_comment])
    assert @rendered_html.include?("fade_level_4"), "Comment was not marked with appropriate fade level"
  end
  
  test "render_threaded_comments child comments of a flagged comment should not be shown" do
    @test_comments[0].flags = 5
    @rendered_html = render_threaded_comments(@test_comments, :flag_threshold => 4)
    @test_comments.each do |comment|
      if(comment.parent_id == @test_comments[0].id)
        assert !@rendered_html.include?(comment.name), "render_threaded_comments should not show child comments of a flagged comment"
      end
    end
  end
  
  test "sort_comments: comments should be sorted by age if ratings are all equal" do
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 3.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 2.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 1.hours.ago)
    sorted_comments = sort_comments(comments)
    comments.reverse!
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "sort_comments: comments should be sorted by rating if ages are all equal" do
    age = 1.hours.ago
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 5, :created_at => age)
    comments << Factory.build(:threaded_comment, :rating => 4, :created_at => age)
    comments << Factory.build(:threaded_comment, :rating => 3, :created_at => age)
    comments << Factory.build(:threaded_comment, :rating => 2, :created_at => age)
    sorted_comments = sort_comments(comments)
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "sort_comments: 'hot' comment should be at the top of the comment list" do
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 10, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 5, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 2.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 1.hours.ago)
    sorted_comments = sort_comments(comments)
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "sort_comments: really recent comment should be at the top of the comment list" do
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 10, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 5, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 2.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 1.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 5.minutes.ago)
    sorted_comments = sort_comments(comments)
    comments.insert(0, comments.pop)
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "sort_comments: recent comment should be near the top of the comment list" do
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 10, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 5, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 2.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 1.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 15.minutes.ago)
    sorted_comments = sort_comments(comments)
    comments.insert(1, comments.pop)
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "sort_comments: somewhat recent comment should be near the top of the comment list" do
    comments = []
    comments << Factory.build(:threaded_comment, :rating => 10, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 5, :created_at => 4.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 1, :created_at => 2.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 1.hours.ago)
    comments << Factory.build(:threaded_comment, :rating => 0, :created_at => 35.minutes.ago)
    sorted_comments = sort_comments(comments)
    comments.insert(2, comments.pop)
    assert sorted_comments == comments, "Should be:\n#{comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}\nBut was:\n#{sorted_comments.map{|a| "  #{a.id}, #{a.rating}, #{(Time.now - a.created_at) / 3600}\n"}}"
  end
  
  test "should bucket comments for rendering" do
    test_comments = create_complex_thread(2)
    assert test_comments.first.is_a?(ThreadedComment)
    bucketed_comments = bucket_comments(test_comments)
    assert_not_equal bucketed_comments, test_comments
    assert_equal test_comments.last.id - 1, bucketed_comments.length, bucketed_comments.inspect
  end
  
  test "render_comment_form should use name label from config" do
    passthrough = render_comment_form(@test_comment)
    assert_equal passthrough[:locals][:name_label], THREADED_COMMENTS_CONFIG[:render_comment_form][:name_label]
  end
  
  test "render_comment_form should use email label from config" do
    passthrough = render_comment_form(@test_comment)
    assert_equal passthrough[:locals][:email_label], THREADED_COMMENTS_CONFIG[:render_comment_form][:email_label]
  end
  
  test "render_comment_form should use body label from config" do
    passthrough = render_comment_form(@test_comment)
    assert_equal passthrough[:locals][:body_label], THREADED_COMMENTS_CONFIG[:render_comment_form][:body_label]
  end
  
  test "render_comment_form should use submit label from config" do
    passthrough = render_comment_form(@test_comment)
    assert_equal passthrough[:locals][:submit_label], THREADED_COMMENTS_CONFIG[:render_comment_form][:submit_label]
  end
  
  test "render_comment_form should use name label from options" do
    passthrough = render_comment_form(@test_comment, :name_label => 'test_label')
    assert_equal passthrough[:locals][:name_label], 'test_label'
  end
  
  test "render_comment_form should use email label from options" do
    passthrough = render_comment_form(@test_comment, :email_label => 'test_label')
    assert_equal passthrough[:locals][:email_label], 'test_label'
  end
  
  test "render_comment_form should use body label from options" do
    passthrough = render_comment_form(@test_comment, :body_label => 'test_label')
    assert_equal passthrough[:locals][:body_label], 'test_label'
  end
  
  test "render_comment_form should use submit label from options" do
    passthrough = render_comment_form(@test_comment, :submit_label => 'test_label')
    assert_equal passthrough[:locals][:submit_label], 'test_label'
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

end
