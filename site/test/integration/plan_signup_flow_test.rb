require File.expand_path('../../test_helper', __FILE__)

class PlanSignupFlowTest < ActionDispatch::IntegrationTest
  
  def setup
    WebMock.allow_net_connect!
    https!
    open_session
  end

  def test_credit_card
    {
      'cvv' => '111',
      'cc_no' => '4111 1111 1111 1111',
      'cc_exp_yyyy' => '2015',
      'cc_exp_mm' => '12',
    }
  end

  def user_params
    {:first_name => 'Mike', :last_name => 'Smith', :aria_billing_info => billing_params}
  end
  def billing_params
    {:address1 => '1234 Someplace', :city => 'Somewhere', :state => 'TX', :country => 'US', :zip => '49345'}
  end

  def simple_user
    @simple_user ||= {:web_user => {:rhlogin => uuid, :password => 'password'}}
  end

  def login_simple_user
    post '/login', simple_user
    assert_response :redirect, @response.inspect
    simple_user
  end

  test 'anonymous without prev signin redirected to signup' do
    get '/account/plans'
    assert_response :success

    get '/account/plans/megashift/upgrade'
    assert_redirected_to new_account_path(:then => account_plan_upgrade_path('megashift'))
  end

  test 'anonymous with signin redirected to login' do
    cookies[:prev_login] = true

    get '/account/plans'
    assert_response :success

    get '/account/plans/megashift/upgrade'
    assert_redirected_to login_path(:then => account_plan_upgrade_path('megashift'))
  end

  test 'user can signup' do
    Rails.configuration.expects(:aria_direct_post_name).at_least_once.returns(nil)

    user = login_simple_user

    get '/account/plans'
    assert_response :success

    get '/account/plans/megashift/upgrade'
    assert_redirected_to '/account/plans/megashift/upgrade/edit'

    get '/account/plans/megashift/upgrade/edit'
    assert_response :success

    put '/account/plans/megashift/upgrade/edit', :streamline_full_user => user_params
    assert_redirected_to '/account/plans/megashift/upgrade/payment_method'

    get '/account/plans/megashift/upgrade/payment_method'
    assert_redirected_to '/account/plans/megashift/upgrade/payment_method/new'

    get '/account/plans/megashift/upgrade/payment_method/new'
    assert_response :success

    res = submit_form('form#payment_method', test_credit_card)
    assert Net::HTTPRedirection === res, res.inspect
    redirect = res['Location']
    assert redirect.starts_with?(direct_create_account_plan_upgrade_payment_method_url('megashift')), redirect

    get redirect
    assert_redirected_to '/account/plans/megashift/upgrade/new'

    # Do some direct checking here just to validate
    user = WebUser.new(:rhlogin => user[:web_user][:rhlogin]).extend(Aria::User)
    assert user.has_valid_payment_method?
    assert payment_method = user.payment_method
    assert payment_method.persisted?
    assert payment_method.cc_no.ends_with?(test_credit_card['cc_no'][-4..-1])
    assert_equal test_credit_card['cc_exp_yyyy'].to_i, payment_method.cc_exp_yyyy
    assert_equal test_credit_card['cc_exp_mm'].to_i, payment_method.cc_exp_mm

    get '/account/plans/megashift/upgrade/new'
    assert_response :success

    post '/account/plans/megashift/upgrade', {:plan_id => 'megashift'}
    assert_redirected_to '/account/plan'

    assert_equal 'megashift', User.find(:one, :as => user).plan_id

    get '/account/plan'
    assert_response :success
  end
end if Aria.available?
