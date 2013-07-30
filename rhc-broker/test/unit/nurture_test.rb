require 'test_helper'
require 'mocha/setup'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.stubs(:debug)
    l.stubs(:info)
    l.stubs(:add)
    l
  end
end

class NurtureTest < ActionDispatch::IntegrationTest

  test "nurture post" do
    credentials = Base64.encode64("nologin:nopass")
    headers = {}
    headers["HTTP_ACCEPT"] = "application/json"
    headers["HTTP_AUTHORIZATION"] = "Basic #{credentials}"
    params = { 'json_data' => '{ "action" : "create", "app_uuid" : "abcd" }' }
    request_via_redirect(:POST, "/broker/nurture", params, headers)
    assert_equal @response.status, 200
  end

  test "nurture bulk post" do
    credentials = Base64.encode64("nologin:nopass")
    headers = {}
    headers["HTTP_ACCEPT"] = "application/json"
    headers["HTTP_AUTHORIZATION"] = "Basic #{credentials}"
    params = { :nurture_action => "update_last_access", :gear_timestamps => [{:uuid => "abcd", :access_time => Time.now.strftime("%d/%b/%Y:%H:%M:%S %Z")}]}
    request_via_redirect(:POST, "/broker/nurture", params, headers)
    assert_equal @response.status, 200
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end
end
