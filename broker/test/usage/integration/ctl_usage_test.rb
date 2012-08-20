require 'test_helper'
require 'stickshift-controller'
require 'mocha'

class CtlUsageTest < ActionDispatch::IntegrationTest

  def setup
  end
  
  def teardown
  end

  def ctl_usage_list
    `rhc-admin-ctl-usage --list`
    exit_code = $?
    assert_equal(exit_cpde, 0)
  end

  def ctl_usage_sync
    `rhc-admin-ctl-usage --sync`
    exit_code = $?
    assert_equal(exit_cpde, 0)
  end
end
