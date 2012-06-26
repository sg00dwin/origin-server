require File.expand_path('../../test_helper', __FILE__)

class AriaTest < ActionDispatch::IntegrationTest
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
end if Aria.available?
