ENV["TEST_NAME"] = "usage_integration_user_api_test"
require 'test_helper'
require 'openshift-origin-controller'
require 'mocha'

class UserApiTest < ActionDispatch::IntegrationTest

  USER_COLLECTION_URL = "/broker/rest/user"

  def setup
    @random = gen_uuid[0..9]
    @login = "t#{@random}"
    @headers = {}
    @headers["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("#{@login}:password")
    @headers["HTTP_ACCEPT"] = "application/json"
    https!
  end

  def teardown
    cloud_user = CloudUser.find_by(login: @login)
    cloud_user.force_delete unless cloud_user.nil?
  end

  def test_user_show
    request_via_redirect(:get, USER_COLLECTION_URL, {}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")
    assert_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 3)
    assert_equal(user["capabilities"]["gear_sizes"], ["small"])
    assert_equal(user["capabilities"].has_key?("max_untracked_addtl_storage_per_gear"), false)
    assert_equal(user["capabilities"].has_key?("max_tracked_addtl_storage_per_gear"), false)
    user = CloudUser.find_by(login: @login)
  end

  def test_user_upgrade
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    api.update_acct_status(acct_no, 1)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "silver")
    assert_not_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 16)
    assert_equal(user["capabilities"]["gear_sizes"].sort, ["medium", "small"])
    assert_equal(user["capabilities"]["max_storage_per_gear"], 5)

    user = CloudUser.find_by(login: @login)
    assert_equal(user.pending_plan_id, nil)
    assert_equal(user.pending_plan_uptime, nil)
    #assert plan changed in billing provider
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
    plans = api.get_queued_service_plans(acct_no)
    assert(plans == nil)
  end

  def test_user_downgrade
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :silver)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")
    assert_not_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 3)
    assert_equal(user["capabilities"]["gear_sizes"], ["small"])
    assert_equal(user["capabilities"].has_key?("max_untracked_addtl_storage_per_gear"), false)
    assert_equal(user["capabilities"].has_key?("max_tracked_addtl_storage_per_gear"), false)

    user = CloudUser.find_by(login: @login)
    assert_equal(user.pending_plan_id, nil)
    assert_equal(user.pending_plan_uptime, nil)
    #assert plan changed in billing provider
    plans = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["new_plan"], "Free", "Current plan name #{current_plan["new_plan"]} expected Free")
  end

  def test_user_downgrade_with_too_many_gears
    user = CloudUser.new(login: @login)
    Lock.create_lock(user)
    user.consumed_gears = 10
    user.save!
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 153)
  end

  def test_user_downgrade_with_large_gears
    user = CloudUser.new(login: @login)
    Lock.create_lock(user)
    user_capabilities = user.get_capabilities
    user_capabilities['gear_sizes'] = ["small", "medium"]
    user.set_capabilities(user_capabilities)
    user.save!
    #create app with large gears
    request_via_redirect(:post, "/broker/rest/domains", {:id=> @login[0..15]}, @headers)
    assert_response :created
    body = JSON.parse(@response.body)
    domain_id = body["data"]["id"]
    request_via_redirect(:post, "/broker/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3", :gear_profile => "medium"}, @headers)
    assert_response :created
    body = JSON.parse(@response.body)
    app = body["data"]
    gear_profile = app["gear_profile"]
    assert_equal(gear_profile, "medium")

    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 154)
  end

  def test_user_downgrade_with_additional_storage
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :ok
    #create app and add additional storage to the gear group
    request_via_redirect(:post, "/broker/rest/domains", {:id=> @login[0..15]}, @headers)
    assert_response :created
    body = JSON.parse(@response.body)
    domain_id = body["data"]["id"]
    request_via_redirect(:post, "/broker/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3"}, @headers)
    assert_response :created
    request_via_redirect(:put, "/broker/rest/domains/#{domain_id}/applications/app/cartridges/php-5.3", {:additional_gear_storage => 1}, @headers)
    assert_response :ok

    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 159)
  end

  def test_user_downgrade_with_certificates
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    assert_equal(body["data"]["capabilities"]["private_ssl_certificates"], true)
    #create app and add certificate
    request_via_redirect(:post, "/broker/rest/domains", {:id=> @login[0..15]}, @headers)
    assert_response :created
    body = JSON.parse(@response.body)
    domain_id = body["data"]["id"]
    request_via_redirect(:post, "/broker/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3"}, @headers)
    assert_response :created
    ssl_certificate_data
    request_via_redirect(:post, "/broker/rest/domains/#{domain_id}/applications/app/aliases", {:id => "as.#{@login[0..15]}", :ssl_certificate => @ssl_certificate, :private_key => @private_key, :pass_phrase => @pass_phrase}, @headers)
    assert_response :created

    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 176)
  end

  def test_user_upgrade_with_inactive_user
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    api.update_acct_status(acct_no, 0)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 152)

    #assert plan  did not change in billing provider
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Free", "Current plan name #{current_plan["plan_name"]} expected Free")
    plans = api.get_queued_service_plans(acct_no)
    assert(plans == nil)
  end

  def test_billing_account_not_found
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 155)
  end

  def test_invalid_plan_id
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    api.update_acct_status(acct_no, 1)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :bogusplan}, @headers)
    assert_response :unprocessable_entity
    body = JSON.parse(@response.body)
    assert_equal(body["messages"][0]["exit_code"], 150)
  end

  def test_plan_upgrade_free_to_mega_recovery
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")
    assert_not_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 3)
    assert_equal(user["capabilities"]["gear_sizes"], ["small"])
    assert_equal(user["capabilities"].has_key?("max_untracked_addtl_storage_per_gear"), false)
    assert_equal(user["capabilities"].has_key?("max_tracked_addtl_storage_per_gear"), false)

    #simulate free to silver failure
    user = CloudUser.find_by(login: @login)
    user.pending_plan_id = "silver"
    user.pending_plan_uptime = Time.now.utc-1000
    user.plan_state = "PENDING"
    user.save!

    `rhc-admin-ctl-plan --fix --login #{@login}`

    user = CloudUser.find_by(login: @login)
    user_capabilities = user.get_capabilities
    assert_equal(user.plan_id, "silver")
    assert_not_equal(user.usage_account_id, nil)
    assert_equal(user.max_gears, 16)
    assert_equal(user_capabilities["gear_sizes"].sort, ["medium", "small"])
    assert_equal(user_capabilities["max_untracked_addtl_storage_per_gear"], 5)
    assert_equal(user_capabilities["max_tracked_addtl_storage_per_gear"], 0)
    assert_equal(user.pending_plan_id, nil)
    assert_equal(user.pending_plan_uptime, nil)
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    assert_equal(plans[0]["plan_name"], "Silver", "Current plan name #{plans[0]["plan_name"]} expected Silver")
    plans = api.get_queued_service_plans(acct_no)
    assert(plans == nil)
  end

  def test_plan_upgrade_mega_to_free_recovery
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :silver)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "silver")
    assert_not_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 16)
    assert_equal(user["capabilities"]["gear_sizes"].sort, ["medium", "small"])
    assert_equal(user["capabilities"]["max_storage_per_gear"], 5)

    #simulate silver to free failure
    user = CloudUser.find_by(login: @login)
    user.pending_plan_id = "free"
    user.pending_plan_uptime = Time.now.utc-1000
    user.plan_state = "PENDING"
    user.save!

    `rhc-admin-ctl-plan --fix --login #{@login}`

    user = CloudUser.find_by(login: @login)
    user_capabilities = user.get_capabilities
    assert_equal(user.plan_id, "free")
    assert_not_equal(user.usage_account_id, nil)
    assert_equal(user.max_gears, 3)
    assert_equal(user_capabilities["gear_sizes"], ["small"])
    assert_equal(user["capabilities"].has_key?("max_untracked_addtl_storage_per_gear"), false)
    assert_equal(user["capabilities"].has_key?("max_tracked_addtl_storage_per_gear"), false)
    assert_equal(user.pending_plan_id, nil)
    assert_equal(user.pending_plan_uptime, nil)
    plans = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["new_plan"], "Free", "Current plan name #{current_plan["new_plan"]} expected Free")
  end

  def test_plan_upgrade_noplan_to_mega_recovery_success
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:get, USER_COLLECTION_URL, {}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")
    assert_equal(user["usage_account_id"], nil)
    assert_equal(user["max_gears"], 3)
    assert_equal(user["capabilities"]["gear_sizes"], ["small"])
    assert_equal(user["capabilities"].has_key?("max_untracked_addtl_storage_per_gear"), false)
    assert_equal(user["capabilities"].has_key?("max_tracked_addtl_storage_per_gear"), false)

    #simulate noplan to silver failure
    user = CloudUser.find_by(login: @login)
    assert_equal(user.plan_id, "free")
    user.pending_plan_id = "silver"
    user.pending_plan_uptime = Time.now.utc-1000
    user.plan_state = "PENDING"
    user.save!

    `rhc-admin-ctl-plan --fix --login #{@login}`

    user = CloudUser.find_by(login: @login)
    user_capabilities = user.get_capabilities
    assert_equal(user.plan_id, "silver")
    assert_not_equal(user.usage_account_id, nil)
    assert_equal(user.max_gears, 16)
    assert_equal(user_capabilities["gear_sizes"].sort, ["medium", "small"])
    assert_equal(user_capabilities["max_untracked_addtl_storage_per_gear"], 5)
    assert_equal(user_capabilities["max_tracked_addtl_storage_per_gear"], 0)
    assert_equal(user.pending_plan_id, nil)
    assert_equal(user.pending_plan_uptime, nil)
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    assert_equal(plans[0]["plan_name"], "Silver", "Current plan name #{plans[0]["plan_name"]} expected Silver")
    plans = api.get_queued_service_plans(acct_no)
    assert(plans == nil)
  end

  def test_fix_user_plan_capabilities_success
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")
    assert_equal(user["max_gears"], 3)

    #simulate user with valid plan but has inconsistent capabilities that can be fixed
    user = CloudUser.find_by(login: @login)
    user.max_gears = 10
    user.save!

    `rhc-admin-ctl-plan --fix --login #{@login}`

    user = CloudUser.find_by(login: @login)
    assert_equal(user.plan_id, "free")
    assert_equal(user.max_gears, 3)
  end

  def test_fix_user_plan_capabilities_failure
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "free")

    #simulate user with valid plan but has inconsistent capabilities that can't be fixed
    user = CloudUser.find_by(login: @login)
    user_capabilities = user.get_capabilities
    user.capabilities_will_change!
    user_capabilities["gear_sizes"].push("c9")
    user.set_capabilities(user_capabilities)
    user.save!
    request_via_redirect(:post, "/broker/rest/domains", {:id=> @login[0..15]}, @headers)
    assert_response :created
    body = JSON.parse(@response.body)
    domain_id = body["data"]["id"]
    request_via_redirect(:post, "/broker/rest/domains/#{domain_id}/applications", {:name => "app", :cartridge => "php-5.3", :gear_profile => "c9"}, @headers)
    assert_response :created

    `rhc-admin-ctl-plan --fix --login #{@login}`

    user = CloudUser.find_by(login: @login)
    user_capabilities = user.get_capabilities
    assert_equal(user.plan_id, "free")
    assert_equal(user_capabilities["gear_sizes"].sort, ["c9", "small"])
  end

  def test_user_queued_plans
    api = OpenShift::BillingService.instance
    user_id = Digest::MD5::hexdigest(@login)
    acct_no = api.create_fake_acct(user_id, :free)
    request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
    assert_response :ok
    body = JSON.parse(@response.body)
    user = body["data"]
    assert_equal(user["plan_id"], "silver")
    acct_details = api.get_acct_details_all(acct_no)
    assert_equal(acct_details["plan_name"], "Silver")
    queued_plans = api.get_queued_service_plans(acct_no)
    assert_equal(queued_plans, nil)

    2.times do
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :free}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "free")
      acct_details = api.get_acct_details_all(acct_no)
      assert_equal(acct_details["plan_name"], "Silver")
      queued_plans = api.get_queued_service_plans(acct_no)
      assert_equal(queued_plans[0]["new_plan"], "Free")
    end
    2.times do
      request_via_redirect(:put, USER_COLLECTION_URL, {:plan_id => :silver}, @headers)
      assert_response :ok
      body = JSON.parse(@response.body)
      user = body["data"]
      assert_equal(user["plan_id"], "silver")
      acct_details = api.get_acct_details_all(acct_no)
      assert_equal(acct_details["plan_name"], "Silver")
      queued_plans = api.get_queued_service_plans(acct_no)
      assert_equal(queued_plans, nil)
    end
  end

  def ssl_certificate_data
    @ssl_certificate = "-----BEGIN CERTIFICATE-----
MIIDoDCCAogCCQDzF8AJCHnrbjANBgkqhkiG9w0BAQUFADCBkTELMAkGA1UEBhMC
VVMxCzAJBgNVBAgMAkNBMRIwEAYDVQQHDAlTdW5ueXZhbGUxDzANBgNVBAoMBnJl
ZGhhdDESMBAGA1UECwwJb3BlbnNoaWZ0MRIwEAYDVQQDDAlvcGVuc2hpZnQxKDAm
BgkqhkiG9w0BCQEWGWluZm9Ab3BlbnNoaWZ0LnJlZGhhdC5jb20wHhcNMTMwMjE5
MjExMTQ4WhcNMTQwMjE5MjExMTQ4WjCBkTELMAkGA1UEBhMCVVMxCzAJBgNVBAgM
AkNBMRIwEAYDVQQHDAlTdW5ueXZhbGUxDzANBgNVBAoMBnJlZGhhdDESMBAGA1UE
CwwJb3BlbnNoaWZ0MRIwEAYDVQQDDAlvcGVuc2hpZnQxKDAmBgkqhkiG9w0BCQEW
GWluZm9Ab3BlbnNoaWZ0LnJlZGhhdC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQDAEbH4MCi3iIDP1HS+/Xwu8SjdSc5WJX6htV7hJpmFZ8HohV/8
ba0v6aM9IJIIt+sIe2J62t/9G3leOdIHBxeACN4fV2l/iA/fvxvlnFKeD7sHm9Oc
Yj1H6YYJ57sIOf/oLDpJl6l3Rw8VC3+3W0/lzlVpA8qt7fpkiW7XQJCPplUSrdVC
3okQ2T5NAod5+wVIOqELgE5bLX1LRs5VPsjytHkJ7rKXs55FHR3kpsoImn5xD0Ky
6lRn8cIMolQoyN5HIGr8f5P+07hrHibve8jje/DKTssb5yEUAEmh6iGHQsRAnsUW
QoIEUOLqQCu9re2No4G52Kl2xQIjyJF7rCfxAgMBAAEwDQYJKoZIhvcNAQEFBQAD
ggEBAGHrya/ZkiAje2kHsOajXMlO2+y1iLfUDcRLuEWpUa8sI5EM4YtemQrsupFp
8lVYG5C4Vh8476oF9t8Wex5eH3ocwbSvPIUqE07hdmrubiMq4wxFVRYq7g9lHAnx
l+bABuN/orbAcPcGAGg7AkXVoAc3Fza/ZcgMcw7NOtDTEss70V9OdgCfQUJL0KdO
hCO8bQ1EaEiq6zEh8RpZe8mu+f/GYATX1I+eJUc6F6cn83oJjE9bqAVzk7TzTHeK
EBKN50C14wWtXeG7n2+ugaVO+0xnvHeUrQBLHSRyOHqxXrQQ5XmzcaBiyI0f2IQM
Hst1BVXyX0n/L/ZoYYsv5juJmDo=
-----END CERTIFICATE-----"
    @private_key = "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAwBGx+DAot4iAz9R0vv18LvEo3UnOViV+obVe4SaZhWfB6IVf
/G2tL+mjPSCSCLfrCHtietrf/Rt5XjnSBwcXgAjeH1dpf4gP378b5ZxSng+7B5vT
nGI9R+mGCee7CDn/6Cw6SZepd0cPFQt/t1tP5c5VaQPKre36ZIlu10CQj6ZVEq3V
Qt6JENk+TQKHefsFSDqhC4BOWy19S0bOVT7I8rR5Ce6yl7OeRR0d5KbKCJp+cQ9C
supUZ/HCDKJUKMjeRyBq/H+T/tO4ax4m73vI43vwyk7LG+chFABJoeohh0LEQJ7F
FkKCBFDi6kArva3tjaOBudipdsUCI8iRe6wn8QIDAQABAoIBAG/on4JVRRQSw8LU
LiWt+jI7ryyoOUH2XL8JtzuGSwLwvomlVJT2rmbxQXx3Qr8zsgziHzIn30RRQrkF
BXu0xRuDjzBBtSVqeJ1Mc4uoNncEAVxgjb5bewswZDnXPCGB8bosMtX4OPRXgdEo
PwTtfjMOsrMaU3hd5Xu4m81tQA2BvwOlx8aYDyH0jeTnervc5uRGbeTBQG4Bu40E
rWNmXvgNq2EzTAwbbN6Ma97gw9KgXnM4Nlh29Fxb5TBeUU9lkzuTZAZIDXKIm7AG
UwMbj/A038yAumYQtThTE/3e4W3rn7F2Vko900bC4aAC1KQOAzjIeQqzqkVxWTWq
4SUFQAECgYEA/ODwifOTuI6hdZK6JRgc4wp6Rc0fkqHuxLzABXoIGuSVlWyimqIN
ZySAkpo5EW6DNraRJxNCOBmWeGPEhHGrea+JPiPEwCK0F7SxvSmg3jzNzw3Es31T
ecET7eDwuSOY9v4XDzLyiXXkEUUReD7Ng2hEYL+HaQrl5jWj4lxgq/ECgYEAwnCb
Krz7FwX8AqtFAEi6uUrc12k1xYKQfrwSxbfdK2vBBUpgB71Iq/fqP+1BittEljDG
8f4jEtMBFfEPhLzGIHaI3UiHUHXS4GetA77TRgR8lnKKpj1FcMIY2iKU479707O5
Q08pgWRUDQ8BVg2ePgbo5QjLMc/rv7UF3AHvPAECgYB/auAIwqDGN6gHU/1TP4ke
pWLi1O55tfpXSzv+BnUbB96PQgPUop7aP7xBIlBrBiI7aVZOOBf/qHT3CF421geu
8tHWa7NxlIrl/vgn9lfGYyDYmXlpb1amXLEsBVGGF/e1TGZWFDe9J5fZU9HvosVu
1xTNIvSZ6xHYI2MGZcGYIQKBgEYeebaV5C7PV6xWu1F46O19U9rS9DM//H/XryVi
Qv4vo7IWuj7QQe7SPsXC98ntfPR0rqoCLf/R3ChfgGsr8H8wf/bc+v9HHj8S5E/f
dy1e3Nccg2ej3PDm7jNsGSlwmmUkAQGHAL7KwYzcBm1UB+bycvZ1j2FtS+UckPpg
MDgBAoGALD8PkxHb4U4DtbNFSYRrUdvS9heav/yph3lTMfifNkOir36io6v8RPgb
D2bHKKZgmYlTgJrxD45Er9agC5jclJO35QRU/OfGf3GcnABkBI7vlvUKADAo65Sq
weZkdJnbrIadcvLOHOzkKC9m+rxFTC9VoN1dwK2zwYvUXfa1VJA=
-----END RSA PRIVATE KEY-----"
    @pass_phrase = "abcd"
  end
end
