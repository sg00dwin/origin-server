require 'test_helper'
require 'stickshift-controller'
require 'mocha'

class AccountApiTest < ActionDispatch::IntegrationTest

  PLANS_COLLECTION_URL = "/rest/plans"
  def setup
    @test_enabled = false 
    @random = gen_uuid[0..9]
    @login = "test_user#{@random}"
    @headers = {}
    @headers["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("#{@login}:password")
    @headers["HTTP_ACCEPT"] = "application/json"
    https!
  end

  def teardown

  end

  def test_plan_show
    if @test_enabled
      request_via_redirect(:get, PLANS_COLLECTION_URL + "/#{:freeshift}", {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      plan = body["data"]
      assert_equal(plan["id"], "freeshift", "Plan id #{plan["id"]} expected freeshift")
      assert_equal(plan["name"], "FreeShift", "Plan name #{plan["name"]} expected FreeShift")
      assert_not_nil(plan["plan_no"])

      request_via_redirect(:get, PLANS_COLLECTION_URL + "/#{:megashift}", {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      plan = body["data"]
      assert_equal(plan["id"], "megashift", "Plan id #{plan["id"]} expected megashift")
      assert_equal(plan["name"], "MegaShift", "Plan name #{plan["name"]} expected MegaShift")
      assert_not_nil(plan["plan_no"])
    end
  end

  def test_plan_index
    if @test_enabled
      request_via_redirect(:get, PLANS_COLLECTION_URL, {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      plans = body["data"]
      assert(plans.length > 1)
      plans.each do |plan|
        assert_not_nil(plan["id"], "Id for plan in nil")
        assert_not_nil(plan["name"], "Name for plan #{plan["id"]} is nil")
        assert_not_nil(plan["plan_no"], "Plan no for plan #{plan["id"]} is nil")
      end
    end
  end

end
