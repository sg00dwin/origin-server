ENV["TEST_NAME"] = "usage_funtional_billing_test"
require 'test_helper'

class BillingTest < ActiveSupport::TestCase
  def setup
    # Create user locally first
    @user = CloudUser.new(login: "billing_testuser_#{gen_uuid[0..9]}")
    @user.save
    @user_id = Digest::MD5::hexdigest(@user.login)
    super
  end

  test "get account no from user id" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)
    assert_not_nil(acct_no, "account number is nil")
    acct_no_from_id = api.get_acct_no_from_user_id(@user_id)
    assert_equal(acct_no, acct_no_from_id, "Account no #{acct_no_from_id} expected #{acct_no}")
  end
  
  test "get account info" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)
    acct_info = api.get_acct_details_all(acct_no)
    assert_equal(acct_info["status_cd"], "1", "Account status #{acct_info["status_cd"]} expected 1")
    assert_equal(acct_info["userid"], @user_id, "Account userid #{acct_info["userid"]} expected #{@user_id}")
  end
  
  test "get plans" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Free", "Current plan name #{current_plan["plan_name"]} expected Free")
    assert_not_nil(current_plan["plan_no"], "plan_no is nil")
  end
  
  test "update account status" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)
    acct_info = api.get_acct_details_all(acct_no)
    assert_equal(acct_info["status_cd"], "1", "Account status #{acct_info["status_cd"]} expected 1")
    api.update_acct_status(acct_no, 0)
    acct_info = api.get_acct_details_all(acct_no)
    assert_equal(acct_info["status_cd"], "0", "Account status #{acct_info["status_cd"]} expected 0")
  end
  
  test "update master plan" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Free", "Current plan name #{current_plan["plan_name"]} expected Free")
    
    api.update_master_plan(acct_no, :silver, true)
    
    plans = api.get_acct_plans_all(acct_no)
    assert(plans.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
  end
  
test "update master plan and then revert to previous" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :free)

    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert_nil queued
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Free", "Current plan name #{current_plan["plan_name"]} expected Free")
      
    api.update_master_plan(acct_no, :silver, true)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert_nil queued
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
      
    api.update_master_plan(acct_no, :free)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert(queued.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
    new_plan = queued[0]
    assert_equal(new_plan["new_plan"], "Free", "New plan name #{new_plan["new_plan"]} expected Free")

    api.update_master_plan(acct_no, :silver, true)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert_nil queued
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
  end
  
  test "update master plan to same plan" do
    api = OpenShift::BillingService.instance
    acct_no = api.create_fake_acct(@user.login, :silver)
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert_nil queued
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
      
    api.update_master_plan(acct_no, :silver)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert_nil queued
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")

    api.update_master_plan(acct_no, :free)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert(queued.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
    new_plan = queued[0]
    assert_equal(new_plan["new_plan"], "Free", "New plan name #{new_plan["new_plan"]} expected Free")

    api.update_master_plan(acct_no, :free)
      
    plans = api.get_acct_plans_all(acct_no)
    queued = api.get_queued_service_plans(acct_no)
    assert(plans.length == 1)
    assert(queued.length == 1)
    current_plan = plans[0]
    assert_equal(current_plan["plan_name"], "Silver", "Current plan name #{current_plan["plan_name"]} expected Silver")
    new_plan = queued[0]
    assert_equal(new_plan["new_plan"], "Free", "New plan name #{new_plan["new_plan"]} expected Free")
  end

  def teardown
    @user.force_delete
  end
end
