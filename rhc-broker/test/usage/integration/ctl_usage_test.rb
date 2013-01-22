require 'test_helper'
require 'openshift-origin-controller'
require 'mocha'

class CtlUsageTest < ActionDispatch::IntegrationTest

  def setup
  end

  def teardown
  end

  test "ctl_usage_sync" do
    login = "user_" + gen_uuid
    cu = CloudUser.new(login: login)
    cu.save!
    Lock.create_lock(cu)
    namespace = "ns" + gen_uuid[0..9]
    domain = Domain.new(namespace: namespace, owner: cu)
    domain.save!
    districts_enabled = Rails.configuration.msg_broker[:districts][:enabled] 
    Rails.configuration.msg_broker[:districts][:enabled] = false
    app_name = "usageapp" + gen_uuid[0..9]
    puts "#{login} <=> #{namespace} <=> #{app_name}"
    begin
      app = Application.create_app(app_name, ['php-5.3'], domain)
    ensure
      Rails.configuration.msg_broker[:districts][:enabled] = districts_enabled
    end
    
    usage_records = []
    UsageRecord.where(login: login).each { |rec| usage_records << rec }
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
      UsageRecord.where(login: login).each { |rec| usage_records << rec }
      assert_equal(1, usage_records.length)
      assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
      assert_equal('small', usage_records[0].gear_size)
      assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    end
    
    # Add fs storage
    app = Application.find_by(name: app_name, domain: domain)
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 5)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(5, group_instance.addtl_fs_gb)

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    usage_records.each do |rec|
    puts rec.inspect
    end
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[1].event)

    # Sync fs storage
    sync_usage

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)

    # Remove fs storage
    app = Application.find_by(domain: domain, canonical_name: 'usageapp')
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 0)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(0, group_instance.addtl_fs_gb)

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(3, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[2].event)

    # Sync removal of fs storage
    sync_usage

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(1, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)

    # Add fs storage back to test removal with gear
    app = Application.find_by(domain: domain, canonical_name: 'usageapp')
    component_instance = app.component_instances.find_by(cartridge_name: 'php-5.3')
    app.update_component_limits(component_instance, 1, 1, 5)
    group_instance = app.group_instances.find_by(_id: component_instance.group_instance_id)
    assert_equal(5, group_instance.addtl_fs_gb)
    
    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(2, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[1].event)
    
    # Delete the app
    app = Application.find_by(domain: domain, canonical_name: 'usageapp')
    app.destroy

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(4, usage_records.length)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[0].usage_type)
    assert_equal(UsageRecord::EVENTS[:continue], usage_records[0].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[1].usage_type)
    assert_equal(UsageRecord::EVENTS[:begin], usage_records[1].event)
    assert_equal(UsageRecord::USAGE_TYPES[:addtl_fs_gb], usage_records[2].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[2].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[3].usage_type)
    assert_equal(UsageRecord::EVENTS[:end], usage_records[3].event)
    assert_equal(UsageRecord::USAGE_TYPES[:gear_usage], usage_records[3].usage_type)

    # Sync the delete
    sync_usage

    usage_records = []
    UsageRecord.where(login: login).asc(:time).each { |rec| usage_records << rec }
    assert_equal(0, usage_records.length)
  end
  
  def sync_usage
    output = `export RAILS_ENV=test; rhc-admin-ctl-usage --sync 2>&1` 
    exit_code = $?.exitstatus
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end
  
  def list_usage
    output = `export RAILS_ENV=test; rhc-admin-ctl-usage --list 2>&1` 
    exit_code = $?.exitstatus
    puts output if exit_code != 0
    assert_equal(0, exit_code)
  end

end
