require 'test_helper'

class AccessFlowsTest < ActionController::IntegrationTest
  test "should get express new" do
    get "/access/express/new"
  end
  
  test "should get flex new" do
    get "/access/flex/new"
  end
end
