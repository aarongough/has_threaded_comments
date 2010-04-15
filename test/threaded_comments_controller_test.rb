require File.dirname(__FILE__) + '/test_helper.rb' 
require 'threaded_comments_controller' 
require 'action_controller/test_process' 

class ThreadedCommentsController
  def rescue_action(e) 
    raise e  
  end 
end 

class ThreadedCommentsControllerTest < ActionController::TestCase 
  def setup 
    @controller = ThreadedCommentsController.new 
    @request = ActionController::TestRequest.new 
    @response = ActionController::TestResponse.new 
    
    ActionController::Routing::Routes.draw do |map| 
      map.flag_threaded_comment          '/threaded-comments/:id/flag', :controller => 'threaded_comments', :action => 'flag', :conditions => { :method => :post }
      map.upmod_threaded_comment         '/threaded-comments/:id/upmod', :controller => 'threaded_comments', :action => 'upmod', :conditions => { :method => :post }
      map.downmod_threaded_comment       '/threaded-comments/:id/downmod', :controller => 'threaded_comments', :action => 'downmod', :conditions => { :method => :post }
      map.create_threaded_comment        '/threaded-comments', :controller => 'threaded_comments', :action => 'create', :conditions => { :method => :post }
      map.remove_threaded_comment_email  '/threaded-comments/:id/remove-email/:hash', :controller => 'threaded_comments', :action => 'remove_email' 
    end  
    
    @sample_comment = {
      :name => 'Test Commenter', 
      :body => 'This the medium size comment body...', 
      :email => "test@example.com", 
      :threaded_comment_polymorphic_id => 1, 
      :threaded_comment_polymorphic_type => 'Book'
    }
    
    @expected_comment_count = ThreadedComment.count + 1
    post :create, :threaded_comment => @sample_comment
    assert_response :success
    assert_equal @expected_comment_count, ThreadedComment.count
  end
  
  def test_should_not_create_comment_if_negative_captcha_is_filled
    assert_no_difference('ThreadedComment.count') do
      put :create, :threaded_comment => @sample_comment.merge({:confirm_email => "test@example.com"})
    end
    assert_response :failure
  end
  
  def test_new
    session[:name] = "Test Name"
    session[:email] = "Test Name"
    get :new, :threaded_comment => @sample_comment.merge({:name => nil, :email => nil})
    assert_response :success
    assert_not_nil assigns(:comment)
    assert @response.body.index(session[:name]), "Response body did not include commenter name"
    assert @response.body.index(session[:email]), "Response body did not include commenter email"
  end
  
  def test_comment_upmod
    @expected_rating = ThreadedComment.find(1).rating + 1
    post :upmod, :id => 1
    assert_response :success
    assert_equal @expected_rating, ThreadedComment.find(1).rating
    assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
  end
  
  def test_comment_downmod
    @expected_rating = ThreadedComment.find(1).rating - 1
    post :downmod, :id => 1
    assert_response :success
    assert_equal @expected_rating, ThreadedComment.find(1).rating
    assert @response.body.index(@expected_rating.to_s), "Response body did not include new rating"
  end
  
  def test_comment_flag
    @expected_flags = ThreadedComment.find(1).flags + 1
    post :flag, :id => 1
    assert_response :success
    assert_equal @expected_flags, ThreadedComment.find(1).flags
  end
  
  def test_should_only_allow_voting_or_flagging_once_per_session
    @actions = [
      { :action => 'flag', :field => 'flags', :difference => 1},
      { :action => 'upmod', :field => 'rating', :difference => 1},
      { :action => 'downmod', :field => 'rating', :difference => -1}
    ]
    @actions.each do |action|
      assert_difference("ThreadedComment.find(1).#{action[:field]}", action[:difference], "Action failed first time: #{action[:action]}") do
        put action[:action], :id => 1
        assert_redirected_to rant_path(Comment.find(1).rant)
      end 
      assert_no_difference( "ThreadedComment.find(1).#{action[:field]}", "Action succeeded when it should have failed: #{action[:action]}") do
        session[:last_url] = rant_path(Comment.find(1).rant)
        put action[:action], :id => 1
        assert_response :success
      end
    end
  end
  
  def test_should_remove_email_notifications_if_hash_matches
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
  
  def test_should_not_remove_email_notifications_if_hash_does_not_match
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