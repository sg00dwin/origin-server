require 'test_helper'

class AccessFlowsTest < ActionController::IntegrationTest
  test "should get index" do
    get "/access/express"
  end
end
