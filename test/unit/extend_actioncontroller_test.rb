require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class ExtendActioncontrollerTest < ActiveSupport::TestCase 

  test "ActionController::Base filter_chain should not be nil" do
    assert ActionController::Base.filter_chain.length > 0
  end
  
end