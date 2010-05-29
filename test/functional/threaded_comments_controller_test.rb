require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ThreadedCommentsControllerTest < ActionController::TestCase

  def setup
    @test_book = Book.create!(Factory.attributes_for(:book))
    ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
    @request.cookies['threaded_comment_cookies_enabled'] = CGI::Cookie.new('threaded_comment_cookies_enabled', 'true')
  end
  
  test "should get show" do
    @test_comment = ThreadedComment.new(Factory.attributes_for(:threaded_comment, :parent_id => 0))
    @test_comment.save
    get :show, :id => @test_comment.id
    assert_response :success, @response.body
    assert_not_nil assigns(:comment)
    assert @response.body.index(@test_comment.name), "Did not include comment name"
    assert @response.body.index(@test_comment.body), "Did not include comment body"
    assert @response.body.index(upmod_threaded_comment_path(@test_comment)), "Did not include link to upmod"
    assert @response.body.index(downmod_threaded_comment_path(@test_comment)), "Did not include link to downmod"
    assert @response.body.index(flag_threaded_comment_path(@test_comment)), "Did not include link to flag"
    assert @response.body.index(new_threaded_comment_path), "Did not include link to new"
  end
  
  test "show should not display threaded comments with flags greater than flag_threshold" do
    @test_comment = ThreadedComment.new(Factory.attributes_for(:threaded_comment, :name => "Flagged Commenter"))
    @test_comment.flags = 99999999
    @test_comment.save
    get :show, :id => @test_comment.id
    assert_response :success, @response.body
    assert_not_nil assigns(:comment)
    assert_nil @response.body.index(@test_comment.name), "Should not include comment name"
    assert_nil @response.body.index(@test_comment.body), "Should not include comment body"
  end
  
  test "should create comment" do
    assert_difference('ThreadedComment.count') do
      @test_comment = Factory.attributes_for(:threaded_comment)
      put :create, :threaded_comment => @test_comment
      assert_response :success
      assert @response.body.index(@test_comment[:name]), "Did not include comment name"
      assert @response.body.index(@test_comment[:body]), "Did not include comment body"
    end
  end
  
  test "should create sub-comment" do
    @test_parent_comment = @test_book.comments.create!(Factory.attributes_for(:threaded_comment))
    @test_comment = Factory.attributes_for(:threaded_comment, :parent_id => @test_parent_comment.id.to_s)
    assert_difference('ThreadedComment.count') do
      put :create, :threaded_comment => @test_comment
      assert_response :success
      assert @response.body.index(@test_comment[:name]), "Did not include comment name"
      assert @response.body.index(@test_comment[:body]), "Did not include comment body"
    end
  end
  
  test "should not create comment if negative captcha is filled" do
    assert_no_difference('ThreadedComment.count') do
      put :create, :threaded_comment => Factory.attributes_for(:threaded_comment, :confirm_email => "test@example.com")
    end
    assert_response :bad_request
  end
  
  test "should get new" do
    session[:name] = "Test Name"
    session[:email] = "Test Name"
    @test_comment = Factory.attributes_for(:threaded_comment, :name => nil, :email => nil, :parent_id => "2")
    get :new, :threaded_comment => @test_comment
    assert_response :success
    assert_not_nil assigns(:comment)
    assert @response.body.include?(session[:name]), "Response body did not include commenter name"
    assert @response.body.include?(session[:email]), "Response body did not include commenter email"
    assert @response.body.include?(@test_comment[:body]), "Response body did not include body"
    assert @response.body.include?(@test_comment[:threaded_comment_polymorphic_id].to_s), "Response body did not include threaded_comment_polymorphic_id"
    assert @response.body.include?(@test_comment[:threaded_comment_polymorphic_type]), "Response body did not include threaded_comment_polymorphic_type"
    assert @response.body.include?(@test_comment[:parent_id]), "Response body did not include parent_id"
    assert @response.body.include?("threaded_comment[name]"), "Response body did not include form for name"
    assert @response.body.include?("threaded_comment[body]"), "Response body did not include form for body"
    assert @response.body.include?("threaded_comment[email]"), "Response body did not include form for email"
    assert @response.body.include?("threaded_comment[threaded_comment_polymorphic_id]"), "Response body did not include form for threaded_comment_polymorphic_id"
    assert @response.body.include?("threaded_comment[threaded_comment_polymorphic_type]"), "Response body did not include form for threaded_comment_polymorphic_type"
    assert @response.body.include?("threaded_comment[parent_id]"), "Response body did not include form for parent_id"
    assert @response.body.include?("threaded_comment[#{THREADED_COMMENTS_CONFIG[:render_comment_form][:honeypot_name]}]"), "Response body did not include honeypot form"
    assert @response.body.include?(THREADED_COMMENTS_CONFIG[:render_comment_form][:name_label]), "Response body did not include name label"
    assert @response.body.include?(THREADED_COMMENTS_CONFIG[:render_comment_form][:email_label]), "Response body did not include email label"
    assert @response.body.include?(THREADED_COMMENTS_CONFIG[:render_comment_form][:body_label]), "Response body did not include body label"
    assert @response.body.include?(THREADED_COMMENTS_CONFIG[:render_comment_form][:submit_title]), "Response body did not include submit title"
    assert @response.body.include?('removeChild(message)'), "Response body did not include javascript callback for removing no_comments_message" 
  end
  
  test "should upmod comment" do
    assert_difference('ThreadedComment.find(1).rating') do
      post :upmod, :id => 1
      assert_response :success
      assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
    end
  end
  
  test "upmodding non-existant comment should cause error" do
    post :upmod, :id => 9999999
    assert_response :error
  end
  
  test "should downmod comment" do
    assert_difference('ThreadedComment.find(1).rating', -1) do
      post :downmod, :id => 1
      assert_response :success
      assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
    end
  end
  
  test "downmodding non-existant comment should cause error" do
    post :downmod, :id => 9999999
    assert_response :error
  end
  
  test "should flag comment" do
    assert_difference('ThreadedComment.find(1).flags') do
      post :flag, :id => 1
      assert_response :success
    end
  end
  
  test "flagging non-existant comment should cause error" do
    post :flag, :id => 9999999
    assert_response :error
  end
  
  test "should only allow rating or flagging once per action per session" do
    @actions = [
      { :action => 'flag', :field => 'flags', :difference => 1},
      { :action => 'upmod', :field => 'rating', :difference => 1},
      { :action => 'downmod', :field => 'rating', :difference => -1}
    ]
    @actions.each do |action|
      test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
      assert_difference("test_comment.#{action[:field]}", action[:difference], "Action failed first time: #{action[:action]}") do
        put action[:action], :id => test_comment.id
        assert_response :success
        test_comment.reload
      end 
      assert_no_difference( "test_comment.#{action[:field]}", "Action succeeded when it should have failed: #{action[:action]}") do
        put action[:action], :id => test_comment.id
        assert_response :bad_request
        test_comment.reload
      end
    end
  end
  
  test "actions should fail if cookies are disabled" do
    @request.cookies['threaded_comment_cookies_enabled'] = nil
    @actions = [
      { :action => 'flag', :field => 'flags', :difference => 1},
      { :action => 'upmod', :field => 'rating', :difference => 1},
      { :action => 'downmod', :field => 'rating', :difference => -1}
    ]
    @actions.each do |action|
      test_comment = ThreadedComment.create!(Factory.attributes_for(:threaded_comment))
      assert_no_difference("test_comment.#{action[:field]}", "Action failed first time: #{action[:action]}") do
        put action[:action], :id => test_comment.id
        assert_response :bad_request
        test_comment.reload
      end
    end
  end
  
  test "should remove email notifications if hash matches" do
    test_comment = ThreadedComment.find(1)
    assert !test_comment.email.empty?
    assert test_comment.notifications == true
    get :remove_notifications, :id => 1, :hash => test_comment.email_hash
    assert_response :success
    test_comment.reload
    assert !test_comment.email.empty?
    assert test_comment.notifications == false
    assert @response.body.index( "removed" ), "Removal notice was not included in response body"
  end
  
  test "should not remove email notifications if hash does not match" do
    test_comment = ThreadedComment.find(1)
    assert !test_comment.email.empty?
    assert test_comment.notifications == true
    get :remove_notifications, :id => 1, :hash => test_comment.email_hash + "1"
    assert_response :success
    test_comment.reload
    assert !test_comment.email.empty?
    assert test_comment.notifications == true
    assert @response.body.index( "The information you provided does not match" ), "Failure notice was not included in response body"
  end
end