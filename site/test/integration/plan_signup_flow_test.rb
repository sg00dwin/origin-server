require File.expand_path('../../test_helper', __FILE__)

class PlanSignupFlowTest < ActionDispatch::IntegrationTest
  
  def setup
    WebMock.allow_net_connect!
    https!
    open_session
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
    assert_redirected_to new_account_path(:then => account_plan_upgrade_path)
  end

  test 'anonymous with signin redirected to login' do
    cookies[:prev_login] = true

    get '/account/plans'
    assert_response :success

    get '/account/plans/megashift/upgrade'
    assert_redirected_to login_path(:then => account_plan_upgrade_path)
  end

  test 'user can signup' do
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

    user = WebUser.new(:rhlogin => user[:web_user][:rhlogin]).extend(Aria::User)
    user.update_account :status_cd => 1

    #post 'pci' #PCI url
    #assert_redirected_to '/account/upgrade/megashift/new

    get '/account/plans/megashift/upgrade/new'
    assert_response :success

    post '/account/plans/megashift/upgrade', {:plan => {:id => 'megashift'}}
    assert_redirected_to '/account/plan'

    assert_equal 'megashift', User.find(:one, :as => user).plan_id

    get '/account/plan'
    assert_response :success
  end
end if Aria.available?
