require 'test_helper'
require 'stickshift-controller'
require 'mocha'

class CtlUsageTest < ActionDispatch::IntegrationTest

  def setup
  end

  def teardown
  end

  test "ctl_usage_sync" do
    login = "user_" + gen_uuid
    cu = CloudUser.new(login, "1234", nil, "default")
    cu.save
    ns = "namespace_" + gen_uuid
    domain = Domain.new(ns, cu)
    domain.save
    app = Application.new(cu, 'usageapp', nil, 'small', 'php-5.3', nil, false, domain)
    districts_enabled = Rails.configuration.gearchanger[:districts][:enabled] 
    Rails.configuration.gearchanger[:districts][:enabled] = false
    begin
      app.create
      app.execute_connections
    ensure
      Rails.configuration.gearchanger[:districts][:enabled] = districts_enabled
    end
    
    cu = CloudUser.find(login)
    assert_equal(1, cu.usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], cu.usage_records[0].usage_type)
    assert_equal('small', cu.usage_records[0].gear_size)
    assert_equal(UsageRecord::EVENTS[:begin], cu.usage_records[0].event)

    # Make sure this doesn't explode    
    list_usage

    # Sync a couple of times
    2.times do
      sync_usage
  
      cu = CloudUser.find(login)
      assert_equal(1, cu.usage_records.length)
      assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], cu.usage_records[0].usage_type)
      assert_equal('small', cu.usage_records[0].gear_size)
      assert_equal(UsageRecord::EVENTS[:continue], cu.usage_records[0].event)
    end
    
    # Add fs storage
    app = Application.find(cu, 'usageapp')
    gi = app.group_instances[0] 
    gi.set_quota(gi.get_cached_min_storage_in_gb + 1)
    app.save

    assert_equal(1, gi.addtl_fs_gb)

    cu = CloudUser.find(login)
    assert_equal(2, cu.usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], cu.usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], cu.usage_records[1].event)

    # Sync fs storage
    sync_usage

    cu = CloudUser.find(login)
    assert_equal(2, cu.usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], cu.usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], cu.usage_records[1].event)

    # Remove fs storage
    app = Application.find(cu, 'usageapp')
    gi = app.group_instances[0] 
    gi.set_quota(gi.get_cached_min_storage_in_gb)
    app.save

    assert_equal(0, gi.addtl_fs_gb)

    cu = CloudUser.find(login)
    assert_equal(3, cu.usage_records.length)
    assert_equal(UsageRecord::EVENTS[:continue], cu.usage_records[1].event)
    assert_equal(UsageRecord::EVENTS[:end], cu.usage_records[2].event)

    # Sync removal of fs storage
    sync_usage

    cu = CloudUser.find(login)
    assert_equal(1, cu.usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], cu.usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], cu.usage_records[0].event)

    # Add fs storage back to test removal with gear
    app = Application.find(cu, 'usageapp')
    gi = app.group_instances[0] 
    gi.set_quota(gi.get_cached_min_storage_in_gb + 1)
    app.save
    
    assert_equal(1, gi.addtl_fs_gb)
    
    cu = CloudUser.find(login)
    assert_equal(2, cu.usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], cu.usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], cu.usage_records[1].event)
    
    # Delete the app
    app = Application.find(cu, 'usageapp')
    app.cleanup_and_delete

    cu = CloudUser.find(login)
    assert_equal(4, cu.usage_records.length)
    assert_equal(UsageRecord::EVENTS[:continue], cu.usage_records[0].event)
    assert_equal(UsageRecord::EVENTS[:begin], cu.usage_records[1].event)
    assert_equal(UsageRecord::EVENTS[:end], cu.usage_records[2].event)
    assert_equal(UsageRecord::EVENTS[:end], cu.usage_records[3].event)

    # Sync the delete
    sync_usage

    cu = CloudUser.find(login)
    assert_equal(0, cu.usage_records.length)
  end
  
  def sync_usage
    output = `export RAILS_ENV=test; rhc-admin-ctl-usage --sync 2>&1` 
    exit_code = $?
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end
  
  def list_usage
    output = `export RAILS_ENV=test; rhc-admin-ctl-usage --list 2>&1` 
    exit_code = $?
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end

end
