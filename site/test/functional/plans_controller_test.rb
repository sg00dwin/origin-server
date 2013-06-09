# encoding: UTF-8

require File.expand_path('../../test_helper', __FILE__)

class PlansControllerTest < ActionController::TestCase
  def known_plans
    ['free','silver']
  end

  # This will also return 'true' for an empty list.
  # That is intentional so that the @smaller_plans/@bigger plans
  # tests work even when one or the other is an empty list.
  def validate_plan_list(plans)
    plans.each do |plan|
      # These extra properties belong to Aria::MasterPlan
      assert plan.max_gears > 0
      assert plan.gear_sizes.length > 0
      assert_not_equal plan.description, ''

      # Call into our plan test for the common propoerties
      validate_plan(plan)
    end
  end

  def validate_plan(plan)
    assert known_plans.include?(plan.id)
    assert_not_equal plan.name, ''
    assert_match /^\d+$/, plan.plan_no.to_s
  end

  setup { omit_if_aria_is_unavailable }

  test "should redirect index requests to the show action" do
    with_unique_user

    get :index
    assert_response :redirect
    assert_redirected_to :controller => 'plans', :action => 'show'
  end

  test "should redirect to login for an unauthenticated show request" do
    get :show
    assert_response :redirect
    assert_redirected_to login_path(:then => '/account/plan')
  end

  test "should provide plan lists and instantiate user when authenticated" do
    with_unique_user

    get :show
    assert_response :success
    user = assigns(:user)
    current_plan = assigns(:current_plan)
    smaller_plans = assigns(:smaller_plans)
    bigger_plans = assigns(:bigger_plans)

    assert_equal user.plan_id, user.plan.id
    validate_plan(current_plan)

    [assigns(:plans), smaller_plans, bigger_plans].each do |plans|
      validate_plan_list plans
    end

    # Ensure we have a div for the right number of plans
    assert_select "#current_plan .plan", 1
    assert_select "#upgrade .plan", bigger_plans.length
    assert_select "#downgrade .plan", smaller_plans.length

    # Ensure the current plan does not have any buttons
    assert_select "#current_plan .plan .btn", :count => 0
    # Ensure that the Upgrade buttons are primary
    assert_select ".plan .btn-primary", :text => "Upgrade"
  end

  test "should show plan lists in correct currency for default" do
    do_plan_list_currency_test(nil, "$", ["C$","€"])
  end

  test "should show plan lists in correct currency for usd" do
    do_plan_list_currency_test("usd", "$", ["C$","€"])
  end

  test "should show plan lists in correct currency for cad" do
    do_plan_list_currency_test("cad", "C$", ["€"])
  end

  test "should show plan lists in correct currency for eur" do
    do_plan_list_currency_test("eur", "€", ["$"])
  end

  protected

    def do_plan_list_currency_test(currency_cd, currency_symbol, exclude_currency_symbols)
      with_unique_user

      if currency_cd
        @controller.expects(:user_currency_cd).at_least(0).returns(currency_cd)
      end

      get :show
      assert_response :success
      user = assigns(:user)

      assert_select ".plan h4 span:content(?)", /#{Regexp.escape(currency_symbol)}/
      exclude_currency_symbols.each do |exclude_currency_symbol|
        assert_select ".plan h4 span:content(?)", /#{Regexp.escape(exclude_currency_symbol)}/, false
      end

      assert_select ".plan li:content(?)", /#{Regexp.escape(currency_symbol)}/
      exclude_currency_symbols.each do |exclude_currency_symbol|
        assert_select ".plan li:content(?)", /#{Regexp.escape(exclude_currency_symbol)}/, false
      end
    end
end
