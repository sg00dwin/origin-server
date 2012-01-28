require 'test_helper'

class BrokerControllerTest < ActionController::TestCase

  test "nurture" do
    resp = post(:nurture_post, {:json_data => '{"action" : "push", "app_uuid" : "1234"}'})
    assert_equal 200, resp.status
    json = JSON.parse(resp.body)
    
    assert_equal "Success", json["result"]
    assert_equal 0, json["exit_code"]
  end

end

