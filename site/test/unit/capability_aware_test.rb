require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class CapabilityAwareTest
  def session_defaults(*args)
    args.push(nil) if args.length == 3
    args
  end

  test 'old session is correctly deserialized' do
    obj.session[:user_capabilities] = [nil, 0, ['small']]
    assert cap = obj.user_capabilities
    assert_equal Capabilities::UnlimitedGears, cap.max_gears
    assert_equal 0, cap.consumed_gears
    assert_equal [:small], cap.gear_sizes
    assert !cap.plan_upgrade_enabled
  end

  test 'plan_upgrade_enabled set' do
    User.expects(:find).returns(User.new(:max_gears => 1, :capabilities => {:plan_upgrade_enabled => false}))
    assert cap = obj.user_capabilities
    assert_equal session_defaults(1,0,[], false), obj.session[:user_capabilities]
    assert_equal false, cap.plan_upgrade_enabled
  end

  test 'plan_upgrade_enabled true' do
    User.expects(:find).returns(User.new(:max_gears => 1, :capabilities => {:plan_upgrade_enabled => true}))
    assert cap = obj.user_capabilities
    assert_equal session_defaults(1,0,[], true), obj.session[:user_capabilities]
    assert_equal true, cap.plan_upgrade_enabled
  end

  test 'billing_aware detects plan capability' do
    User.expects(:find).returns(User.new(:max_gears => 1, :capabilities => {:plan_upgrade_enabled => true}))
    obj.current_user = true
    obj.extend(BillingAware)
    with_config(:aria_enabled, false) do
      assert !obj.send(:user_can_upgrade_plan?)
    end
    with_config(:aria_enabled, true) do
      assert obj.send(:user_can_upgrade_plan?)
    end
  end

  test 'billing_aware follows plan capability' do
    with_config(:aria_enabled, true) do
      User.expects(:find).returns(User.new(:max_gears => 1, :capabilities => {:plan_upgrade_enabled => false}))
      obj.current_user = true
      obj.extend(BillingAware)
      assert !obj.send(:user_can_upgrade_plan?)
    end
  end
end
