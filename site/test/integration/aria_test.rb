require File.expand_path('../../test_helper', __FILE__)

class AriaIntegrationTest < ActionDispatch::IntegrationTest

  test 'should correctly handle sessions' do
    user = (WebUser.new :rhlogin => new_uuid).extend Aria::User

    assert_nil user.destroy_session

    assert_raise(Aria::AuthenticationError){ user.create_session }
    assert_nil user.destroy_session

    user.create_account

    assert s = user.create_session
    assert s.length > 0

    assert_nil user.destroy_session
    assert_nil user.destroy_session
  end

  test 'should correctly create and validate a simple user' do
    user = (WebUser.new :rhlogin => new_uuid).extend Aria::User

    assert !user.has_valid_account?
    assert !user.send(:has_account?)

    assert user.create_account
    assert user.errors.empty?

    assert_equal 'Y', Aria.get_acct_details_all(user.acct_no).is_test_acct
    assert_equal user.rhlogin, Aria.get_supp_field_value(user.acct_no, :rhlogin)

    assert user.has_valid_account?
    assert user.send(:has_account?)
  end

  test 'should set and update billing info' do
    user = (WebUser.new :rhlogin => new_uuid).extend Aria::User

    methods = Aria::BillingInfo.generated_attribute_methods.instance_methods

    info = Aria::BillingInfo.new

    # create
    methods.each do |m|
      info.send(m, ActiveSupport::SecureRandom.base64(5)) if m.ends_with?('=')
    end
    info.country = 'US'
    info.zip = 12345.to_s
    info.state = 'TX'
    info.middle_initial = 'P'
    #info.tax_exempt = 1
    assert user.create_account(:billing_info => info), user.errors.inspect
    billing_info = user.billing_info
    #info.attributes.delete 'tax_exempt'
    assert_equal info.attributes, billing_info.attributes
    #assert_equal 1, user.tax_exempt
    #assert user.tax_exempt?

    # update
    methods.each do |m|
      info.send(m, ActiveSupport::SecureRandom.base64(5)) if m.ends_with?('=')
    end
    info.country = 'FR'
    info.zip = 54321.to_s
    info.state = 'Loraine'
    info.middle_initial = 'M'
    #info.tax_exempt = 2
    assert user.update_account(:billing_info => info), user.errors.inspect
    billing_info = user.billing_info
    #info.attributes.delete 'tax_exempt'
    assert_equal info.attributes, billing_info.attributes
    #assert_equal 2, user.tax_exempt
    #assert user.tax_exempt?
  end

  test 'should set direct post settings' do
    set = Aria::DirectPost.create('testplan', "https://example.com")

    params = Aria.get_reg_uss_config_params("direct_post_#{set}")
    assert_equal({
      'redirecturl' => 'https://example.com',
      'do_cc_auth' => '1',
      'min_auth_threshold' => '0',
      'change_status_on_cc_auth_success' => '1',
      'status_on_cc_auth_success' => '1',
      'change_status_on_cc_auth_failure' => '1',
      'status_on_cc_auth_failure' => '-1',
    }, params)

    Aria::DirectPost.destroy(set)

    assert Aria.get_reg_uss_config_params("direct_post_#{set}").empty?
  end

  test 'should get plan details' do
    assert plans = Aria.get_client_plans_basic
    assert plans.length > 0
    assert plan = plans[0]
    assert plan.plan_no.is_a? Fixnum
    assert plan.plan_name
    assert_raise(NoMethodError){ plan.not_an_attribute }

    assert r = Aria.get_client_plans_basic_raw
    assert r.data
    assert r.data.plans_basic.length > 0

    assert p = plans.find{ |p| p.plan_no == Aria.default_plan_no }
    assert p['plan_name'] =~ /freeshift/i, p.inspect
  end

  test 'should raise when missing parameter' do
    assert_raise(Aria::MissingRequiredParameter){ Aria.get_acct_comments }
  end

  test 'should raise when method does not exist' do
    assert_raise(Aria::InvalidMethod){ Aria.get_not_a_real_method }
  end

  test 'should provide combined master plans' do
    assert plans = Aria::MasterPlan.all
    assert plans.length > 0
    assert plan = plans[0]
    assert plan.description.is_a? String
    assert plan.max_gears.is_a? Fixnum
    assert plan.gear_sizes.kind_of? Array
    assert plan.gear_sizes.length > 0
  end
end if Aria.available?
