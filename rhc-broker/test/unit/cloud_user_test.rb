ENV["TEST_NAME"] = "unit_cloud_user_test"
require 'test_helper'
require 'mocha/setup'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.stubs(:debug)
    l.stubs(:info)
    l.stubs(:error)
    l.stubs(:add)
    l
  end
end

class CloudUserUnitTest < ActiveSupport::TestCase
  def setup
    @login = "user" + gen_uuid[0..9]
    @namespace = "domain" + gen_uuid[0..9]
  end

  test "create and delete user" do
    @user = CloudUser.new(login: @login)
    @user.save
    @user.delete
  end

  test "match plan capabilities" do
    @user = CloudUser.new(login: @login)
    @user.save
    @user.match_plan_capabilities("free")
    @user.delete
  end

  test "negative assign and update plan" do
    @user = CloudUser.new(login: @login)
    @user.save
    @user.check_plan_compatibility("silver") 
    @user.capabilities['plan_upgrade_enabled'] = false
    begin
      @user.update_plan("silver") 
    rescue Exception=>e
      assert e
    end
    @user.delete
  end

  test "assign and update plan" do
    billing_api = OpenShift::BillingService.instance
    billing = mock()
    OpenShift::BillingService.stubs(:instance).returns(billing)
    billing.stubs(:get_acct_no_from_user_id).returns(1234)
    billing.stubs(:get_plans).returns(billing_api.get_plans)
    billing.stubs(:get_acct_details_all).returns({"status_cd" => 1})
    billing.stubs(:get_queued_service_plans).returns(nil)
    billing.stubs(:update_master_plan).returns(true)
 
    @user = CloudUser.new(login: @login)
    @user.save
    @user.get_billing_account_no
    @user.assign_plan("silver")
    @user.check_plan_compatibility("silver") 
    @user.get_billing_details
    @user.capabilities['plan_upgrade_enabled'] = true
    @user.update_plan("silver")
    @user.delete
  end

  test "get user valid gear sizes" do
    @user = CloudUser.new(login: @login)
    @user.save
    OpenShift::ApplicationContainerProxy.valid_gear_sizes(@user)
    @user.delete
  end

  test "negative get user and domain and delete user" do
    @user = CloudUser.new(login: @login)
    @user.save
    @domain = Domain.new(namespace: @namespace, owner: @user)
    @domain.save
    begin
      @user.delete
    rescue Exception=>e
      assert e
    end
    @domain.delete
    @user.reload
    @user.delete
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end
end

