require 'test_helper'
require 'stickshift-controller'
require 'mocha'

class UserApiTest < ActionDispatch::IntegrationTest

  USER_COLLECTION_URL = "/rest/user"

  def setup
    @test_enabled = false
    @random = gen_uuid[0..9]
    @login = "t#{@random}"
    @headers = {}
    @headers["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("#{@login}:password")
    @headers["HTTP_ACCEPT"] = "application/json"
    https!
  end
  
  def teardown
    if @test_enabled
      cloud_user = CloudUser.find(@login)
      cloud_user.delete unless cloud_user.nil?
    end
  end
  
  def test_user_show
    if @test_enabled
      request_via_redirect(:get, USER_COLLECTION_URL, {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], nil)
      assert_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 3)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)
    end
  end
  
  def test_user_upgrade
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      api.update_acct_status(acct_no, 1)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :megashift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "megashift")
      assert_not_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 16)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"].sort, ["medium", "small"])
      assert_equal(user.capabilities["max_storage_per_gear"], 30)
      assert_equal(user.pending_plan_id, nil)
      assert_equal(user.pending_plan_uptime, nil)
      #assert plan changed in aria
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      current_plan = plans[0]
      assert_equal(current_plan["plan_name"], "MegaShift", "Current plan name #{current_plan["plan_name"]} expected MegaShift")
    end
  end

  def test_user_downgrade
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :megashift)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "freeshift")
      assert_not_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 3)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)
      assert_equal(user.pending_plan_id, nil)
      assert_equal(user.pending_plan_uptime, nil)
      #assert plan changed in aria
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      current_plan = plans[0]
      assert_equal(current_plan["plan_name"], "FreeShift", "Current plan name #{current_plan["plan_name"]} expected FreeShift")
    end
  end
 
  def test_user_downgrade_with_too_many_gears
    if @test_enabled
      user = CloudUser.new(@login)
      user.consumed_gears = 10
      user.save
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 153)
    end
  end
  
  def test_user_downgrade_with_large_gears
    if @test_enabled
      user = CloudUser.new(@login)
      user.capabilities['gear_sizes'] = ["small", "medium"]
      user.save
      #create app with large gears
      request_via_redirect(:post, "/rest/domains", {:id=> @login[0..15]}, @headers)
      assert_response :created
      body = JSON.parse(@response.body)
      domain_id = body["data"]["id"]
      request_via_redirect(:post, "/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3", :gear_profile => "medium"}, @headers)
      assert_response :created
      body = JSON.parse(@response.body)
      app = body["data"]
      gear_profile = app["gear_profile"]
      assert_equal(gear_profile, "medium")
      
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 154)
    end
  end

  def test_user_downgrade_with_additional_storage
    if @test_enabled
      user = CloudUser.new(@login)
      user.save
      #create app and add additional storage to the gear group
      request_via_redirect(:post, "/rest/domains", {:id=> @login[0..15]}, @headers)
      assert_response :created
      body = JSON.parse(@response.body)
      domain_id = body["data"]["id"]
      request_via_redirect(:post, "/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3"}, @headers)
      assert_response :created
      user = CloudUser.find(@login)
      user.applications[0].group_instances[0].addtl_fs_gb = 1
      user.applications[0].save
 
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 159)
    end
  end

  def test_user_upgrade_with_inactive_user
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      api.update_acct_status(acct_no, 0)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :megashift}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 152)
      
      #assert plan  did not change in aria
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      current_plan = plans[0]
      assert_equal(current_plan["plan_name"], "FreeShift", "Current plan name #{current_plan["plan_name"]} expected FreeShift")
    end
  end
  
  def test_aria_account_not_found
    if @test_enabled
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :megashift}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 155)
    end
  end
  
  def test_invalid_plan_id
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      api.update_acct_status(acct_no, 1)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :bogusplan}, @headers)
      assert_response :unprocessable_entity
      body = JSON.parse(@response.body)
      assert_equal(body["messages"][0]["exit_code"], 150)
    end
  end 

  def test_plan_upgrade_free_to_mega_recovery
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "freeshift")
      assert_not_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 3)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)

      #simulate freeshift to megashift failure
      user.pending_plan_id = "megashift"
      user.pending_plan_uptime = Time.now.utc-1000
      user.save

      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, "megashift")
      assert_not_equal(user.usage_account_id, nil)
      assert_equal(user.max_gears, 16)
      assert_equal(user.capabilities["gear_sizes"].sort, ["medium", "small"])
      assert_equal(user.capabilities["max_storage_per_gear"], 30)
      assert_equal(user.pending_plan_id, nil)
      assert_equal(user.pending_plan_uptime, nil)
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      assert_equal(plans[0]["plan_name"], "MegaShift", "Current plan name #{plans[0]["plan_name"]} expected MegaShift")
    end
  end
 
  def test_plan_upgrade_mega_to_free_recovery
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :megashift)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :megashift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "megashift")
      assert_not_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 16)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"].sort, ["medium", "small"])
      assert_equal(user.capabilities["max_storage_per_gear"], 30)

      #simulate megashift to freeshift failure
      user.pending_plan_id = "freeshift"
      user.pending_plan_uptime = Time.now.utc-1000
      user.save

      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, "freeshift")
      assert_not_equal(user.usage_account_id, nil)
      assert_equal(user.max_gears, 3)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)
      assert_equal(user.pending_plan_id, nil)
      assert_equal(user.pending_plan_uptime, nil)
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      assert_equal(plans[0]["plan_name"], "FreeShift", "Current plan name #{plans[0]["plan_name"]} expected FreeShift")
    end
  end
 
  def test_plan_upgrade_noplan_to_mega_recovery_success
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      request_via_redirect(:get, USER_COLLECTION_URL, {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], nil)
      assert_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 3)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)

      #simulate noplan to megashift failure
      user.pending_plan_id = "megashift"
      user.pending_plan_uptime = Time.now.utc-1000
      user.save

      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, "megashift")
      assert_not_equal(user.usage_account_id, nil)
      assert_equal(user.max_gears, 16)
      assert_equal(user.capabilities["gear_sizes"].sort, ["medium", "small"])
      assert_equal(user.capabilities["max_storage_per_gear"], 30)
      assert_equal(user.pending_plan_id, nil)
      assert_equal(user.pending_plan_uptime, nil)
      plans = api.get_acct_plans_all(acct_no)
      assert(plans.length == 1)
      assert_equal(plans[0]["plan_name"], "MegaShift", "Current plan name #{plans[0]["plan_name"]} expected MegaShift")
    end
  end

  def test_plan_upgrade_noplan_to_mega_recovery_failure
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :megashift)
      request_via_redirect(:get, USER_COLLECTION_URL, {}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], nil)
      assert_equal(user["usage_account_id"], nil)
      assert_equal(user["max_gears"], 3)
      user = CloudUser.find(@login)
      assert_equal(user.capabilities["gear_sizes"], ["small"])
      assert_equal(user.capabilities.has_key?("max_storage_per_gear"), false)

      #simulate noplan to megashift failure thats not recoverable
      user.pending_plan_id = "megashift"
      user.pending_plan_uptime = Time.now.utc-1000
      user.capabilities_will_change!
      user.capabilities["gear_sizes"].push("c9")
      user.save
      request_via_redirect(:post, "/rest/domains", {:id=> @login[0..15]}, @headers)
      assert_response :created
      body = JSON.parse(@response.body)
      domain_id = body["data"]["id"]
      request_via_redirect(:post, "/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3", :gear_profile => "c9"}, @headers)
      assert_response :created
 
      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, nil)
      assert_equal(user.pending_plan_id, "megashift")
      assert_not_equal(user.pending_plan_uptime, nil)
    end
  end

  def test_fix_user_plan_capabilities_success
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "freeshift")
      assert_equal(user["max_gears"], 3)

      #simulate user with valid plan but has inconsistent capabilities that can be fixed
      user = CloudUser.find(@login)
      user.max_gears = 10
      user.save

      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, "freeshift")
      assert_equal(user.max_gears, 3)
    end
  end

  def test_fix_user_plan_capabilities_failure
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      user_id = Digest::MD5::hexdigest(@login)
      acct_no = api.create_fake_acct(user_id, :freeshift)
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :freeshift}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "freeshift")
 
      #simulate user with valid plan but has inconsistent capabilities that can't be fixed
      user = CloudUser.find(@login)
      user.capabilities_will_change!
      user.capabilities["gear_sizes"].push("c9")
      user.save
      request_via_redirect(:post, "/rest/domains", {:id=> @login[0..15]}, @headers)
      assert_response :created
      body = JSON.parse(@response.body)
      domain_id = body["data"]["id"]
      request_via_redirect(:post, "/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3", :gear_profile => "c9"}, @headers)
      assert_response :created

      `rhc-admin-ctl-plan --fix --login #{@login}`

      user = CloudUser.find(@login)
      assert_equal(user.plan_id, "freeshift")
      assert_equal(user.capabilities["gear_sizes"].sort, ["c9", "small"])
    end
  end
end
