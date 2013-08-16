ENV["TEST_NAME"] = "usage_integration_cli_usage_test"
require 'test_helper'
require 'openshift-origin-controller'
require 'mocha/setup'

class CtlUsageTest < ActionDispatch::IntegrationTest

  def setup
    @login = "user_" + gen_uuid
    @namespace = "ns" + gen_uuid[0..9]
    @appname = "usageapp" + gen_uuid[0..9]

    cu = CloudUser.new(login: @login)
    @user_id = cu._id
    cu.plan_id = "silver"
    cu.capabilities['max_untracked_addtl_storage_per_gear'] = 5
    cu.capabilities['max_tracked_addtl_storage_per_gear'] = 5
    cu.save!
    Lock.create_lock(cu)
    
    @domain = Domain.new(namespace: @namespace, owner: cu)
    @domain.save!
    @districts_enabled = Rails.configuration.msg_broker[:districts][:enabled] 
    Rails.configuration.msg_broker[:districts][:enabled] = false
    @billing_api = OpenShift::BillingService.instance
  end
  
  def teardown
    # delete the application
    Application.where(domain: @domain, name: @appname).delete

    # delete the domain
    Domain.where(canonical_namespace: @namespace).delete
    
    # delete the user
    CloudUser.where(_id: @user_id).delete
    
    # delete the usage records
    UsageRecord.where(user_id: @user_id).delete
    Usage.where(user_id: @user_id).delete
  end

  def test_gear_storage_usage_sync
    begin
      app = Application.create_app(@appname, ['php-5.3'], @domain)
    ensure
      Rails.configuration.msg_broker[:districts][:enabled] = @districts_enabled
    end
    acct_no = @billing_api.create_fake_acct(@login, :silver)
    cu = CloudUser.find_by(_id: @user_id)
    cu.usage_account_id = acct_no
    cu.save!
    
    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(1, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal('small', usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)

    # Make sure this doesn't explode    
    list_usage

    # Sync a couple of times
    2.times do
      sync_usage
  
      usage_records = []
      UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
      assert_equal(1, usage_records.length)
      assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
      assert_equal('small', usage_records[0].gear_size)
      assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    end
    
    # Add untracked fs storage
    app = Application.find_by(name: @appname, domain: @domain)
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 4)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(4, group_instance.addtl_fs_gb)

    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(1, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal('small', usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)

    # Add tracked fs storage
    app = Application.find_by(name: @appname, domain: @domain)
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 8)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(8, group_instance.addtl_fs_gb)

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(3, usage_records[0].addtl_fs_gb)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)

    # Sync fs storage
    sync_usage

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(3, usage_records[0].addtl_fs_gb)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)

    # Remove tracked fs storage
    app = Application.find_by(name: @appname, domain: @domain)
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 0)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(0, group_instance.addtl_fs_gb)

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).asc(:created_at).each { |rec| usage_records << rec }
    assert_equal(3, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(3, usage_records[0].addtl_fs_gb)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[2].event)

    # Sync removal of fs storage
    sync_usage

    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(1, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)

    # Add tracked fs storage back to test removal with gear
    app = Application.find_by(name: @appname, domain: @domain)
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 8)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(8, group_instance.addtl_fs_gb)
    
    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(3, usage_records[0].addtl_fs_gb)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)
    
    # Delete the app
    app = Application.find_by(name: @appname, domain: @domain)
    app.destroy_app

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).asc(:created_at).each { |rec| usage_records << rec }
    assert_equal(4, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(3, usage_records[0].addtl_fs_gb)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[2].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[3].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[3].event)

    # Sync the delete
    sync_usage

    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(0, usage_records.length)
  end
 
  def test_cartridge_usage_sync
    # Create app with premium cart
    begin
      app = Application.create_app(@appname, ['jbosseap-6'], @domain)
    ensure
      Rails.configuration.msg_broker[:districts][:enabled] = @districts_enabled
    end
    acct_no = @billing_api.create_fake_acct(@login, :silver)
    cu = CloudUser.find_by(_id: @user_id)
    cu.usage_account_id = acct_no
    cu.save!

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal('small', usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[1].usage_type)
    assert_equal('jbosseap-6', usage_records[1].cart_name)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[1].event)

    # List and Sync usage
    list_usage
    sync_usage
  
    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal('small', usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[1].usage_type)
    assert_equal('jbosseap-6', usage_records[1].cart_name)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)

    # Delete current app
    app = Application.find_by(name: @appname, domain: @domain)
    app.destroy_app

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).asc(:created_at).each { |rec| usage_records << rec }
    assert_equal(4, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[2].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[3].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[3].event)

    # Sync usage again
    sync_usage

    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(0, usage_records.length)
  end

  def test_usage_sync_no_billing_account
    # Create app with premium cart
    begin
      app = Application.create_app(@appname, ['jbosseap-6'], @domain)
    ensure
      Rails.configuration.msg_broker[:districts][:enabled] = @districts_enabled
    end
    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal('small', usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[1].usage_type)
    assert_equal('jbosseap-6', usage_records[1].cart_name)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[1].event)

    # Delete current app
    app = Application.find_by(name: @appname, domain: @domain)
    app.destroy_app

    usage_records = []
    UsageRecord.where(user_id: @user_id).asc(:usage_type).asc(:created_at).each { |rec| usage_records << rec }
    assert_equal(4, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[2].event)
    assert_equal(UsageRecord::USAGE_TYPES[:premium_cart], usage_records[3].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[3].event)

    # Sync usage again
    sync_usage

    usage_records = []
    UsageRecord.where(user_id: @user_id).each { |rec| usage_records << rec }
    assert_equal(0, usage_records.length)
  end

  def sync_usage
    output = `export RAILS_ENV=test; oo-admin-ctl-usage --enable-logger --sync 2>&1` 
    exit_code = $?.exitstatus
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end
  
  def list_usage
    output = `export RAILS_ENV=test; oo-admin-ctl-usage --enable-logger --list 2>&1` 
    exit_code = $?.exitstatus
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end
end
