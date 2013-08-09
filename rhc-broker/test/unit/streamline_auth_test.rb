ENV["TEST_NAME"] = "unit_streamline_auth_test"
require 'test_helper'
require 'mocha/setup'

class StreamlineAuthTest < ActiveSupport::TestCase
  test "authentication" do
    mock_request = mock("Request")
    mock_request.expects(:cookies).returns({"rh_sso" => "abcde"})
    mock_controller = mock("Controller")
    mock_controller.extend(AuthenticateWithBasic)
    mock_controller.expects(:request).returns(mock_request)

    Rails.configuration.auth[:integrated] = true
    Rails.configuration.action_controller.perform_caching = true

    assert u = TestAuthService.new.authenticate_request(mock_controller)
    assert_equal 'login', u[:username]
  end

  def teardown
    Rails.configuration.auth[:integrated] = false
    Rails.configuration.action_controller.perform_caching = false
    Mocha::Mockery.instance.stubba.unstub_all
  end
end

module AuthenticateWithBasic
  def authenticate_with_http_basic(&block)
    yield 'login', 'pwd'
  end
end

class TestAuthService < OpenShift::StreamlineAuthService
  def http_post(url, args={}, ticket=nil)
    ticket = "abcde" unless ticket
    return {"username" => "login", "roles" => ["cloud_access_1"]}, ticket
  end
end

class TestCachedAuthService < OpenShift::StreamlineAuthService
  def http_post(url, args={}, ticket=nil)
    # If the authentication ticket is cached, this method should not be called
    raise "If the authentication ticket is cached, auth service should not be called"
  end
end

