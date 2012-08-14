require File.expand_path('../../test_helper', __FILE__)

class PlansControllerTest < ActionController::TestCase
  def known_plans
    ['freeshift','megashift']
  end

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

  test "should provide a plan list even without authentication" do
    get :index
    assert_response :success
    assert_nil assigns(:user)
    assert_nil assigns(:current_plan)
    validate_plan_list(assigns(:plans))
  end

  test "should provide a plan list and instantiate user when authenticated" do
    with_unique_user

    get :index
    assert_response :success
    user = assigns(:user)
    assert_equal user.plan_id, user.plan.id
    validate_plan(assigns(:current_plan))
    validate_plan_list(assigns(:plans))
  end

  test "should redirect to login for an unauthenticated show request" do
    get :show
    assert_redirected_to login_path(:redirectUrl => '/account/plan')
  end

  test "should show a user's current plan when authenticated" do
    with_unique_user

    get :show
    assert_response :success
    user = assigns(:user)
    assert_equal user.plan_id, user.plan.id
    validate_plan(assigns(:plan))
  end
end
