require File.join(File.dirname(__FILE__), '..', 'test_helper.rb')
require 'action_controller/test_process'

class ThreadedCommentsControllerTest < ActionController::TestCase

  def setup    
    @sample_book = {
      :title => "This is a test title",
      :content => "Wow! This item has some content!"
    } 
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => "1", 
      :threaded_comment_polymorphic_type => 'Book'
    }
    @test_book = Book.create!(@sample_book)
    ThreadedComment.create(@sample_comment)
  end
  
  test "should get show" do
    @test_comment = ThreadedComment.new(@sample_comment.merge({:parent_id => 0}))
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
    @test_comment = ThreadedComment.new(@sample_comment.merge({:name => "Flagged Commenter"}))
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
      put :create, :threaded_comment => @sample_comment
      assert_response :success
      assert @response.body.index(@sample_comment[:name]), "Did not include comment name"
      assert @response.body.index(@sample_comment[:body]), "Did not include comment body"
    end
  end
  
  test "should create sub-comment" do
    @test_parent_comment = @test_book.comments.create(@sample_comment)
    assert_difference('ThreadedComment.count') do
      put :create, :threaded_comment => @sample_comment.merge({:parent_id => @test_parent_comment.id.to_s})
      assert_response :success
      assert @response.body.index(@sample_comment[:name]), "Did not include comment name"
      assert @response.body.index(@sample_comment[:body]), "Did not include comment body"
    end
  end
  
  test "should not create comment if negative captcha is filled" do
    assert_no_difference('ThreadedComment.count') do
      put :create, :threaded_comment => @sample_comment.merge({:confirm_email => "test@example.com"})
    end
    assert_response :bad_request
  end
  
  test "should get new" do
    session[:name] = "Test Name"
    session[:email] = "Test Name"
    @test_comment = @sample_comment.merge({:name => nil, :email => nil, :parent_id => "2"})
    get :new, :threaded_comment => @test_comment
    assert_response :success
    assert_not_nil assigns(:comment)
    assert @response.body.index(session[:name]), "Response body did not include commenter name"
    assert @response.body.index(session[:email]), "Response body did not include commenter email"
    assert @response.body.index(@test_comment[:body]), "Response body did not include body"
    assert @response.body.index(@test_comment[:threaded_comment_polymorphic_id].to_s), "Response body did not include threaded_comment_polymorphic_id"
    assert @response.body.index(@test_comment[:threaded_comment_polymorphic_type]), "Response body did not include threaded_comment_polymorphic_type"
    assert @response.body.index(@test_comment[:parent_id]), "Response body did not include parent_id"
    assert @response.body.index("threaded_comment[name]"), "Response body did not include form for name"
    assert @response.body.index("threaded_comment[body]"), "Response body did not include form for body"
    assert @response.body.index("threaded_comment[email]"), "Response body did not include form for email"
    assert @response.body.index("threaded_comment[threaded_comment_polymorphic_id]"), "Response body did not include form for threaded_comment_polymorphic_id"
    assert @response.body.index("threaded_comment[threaded_comment_polymorphic_type]"), "Response body did not include form for threaded_comment_polymorphic_type"
    assert @response.body.index("threaded_comment[parent_id]"), "Response body did not include form for parent_id"
  end
  
  test "should upmod comment" do
    assert_difference('ThreadedComment.find(1).rating') do
      post :upmod, :id => 1
      assert_response :success
      assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
    end
  end
  
  test "should downmod comment" do
    assert_difference('ThreadedComment.find(1).rating', -1) do
      post :downmod, :id => 1
      assert_response :success
      assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
    end
  end
  
  test "should flag comment" do
    assert_difference('ThreadedComment.find(1).flags') do
      post :flag, :id => 1
      assert_response :success
    end
  end
  
  test "should only allow rating or flagging once per action per session" do
    @actions = [
      { :action => 'flag', :field => 'flags', :difference => 1},
      { :action => 'upmod', :field => 'rating', :difference => 1},
      { :action => 'downmod', :field => 'rating', :difference => -1}
    ]
    @actions.each do |action|
      assert_difference("ThreadedComment.find(1).#{action[:field]}", action[:difference], "Action failed first time: #{action[:action]}") do
        put action[:action], :id => 1
        assert_response :success
      end 
      assert_no_difference( "ThreadedComment.find(1).#{action[:field]}", "Action succeeded when it should have failed: #{action[:action]}") do
        put action[:action], :id => 1
        assert_response :bad_request
      end
    end
  end
  
  test "should remove emails notifications if hash matches" do
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