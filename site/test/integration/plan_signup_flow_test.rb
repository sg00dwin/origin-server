require File.expand_path('../../test_helper', __FILE__)

class PlanSignupFlowTest < ActionDispatch::IntegrationTest
  
  def setup
    WebMock.allow_net_connect!
    https!
    open_session
  end

  def user_params
    {:first_name => 'Mike', :last_name => 'Smith'}
  end

  def login_simple_user
    post '/login', {:web_user => {:rhlogin => 'test@test.com', :password => 'password'}}
    assert_response :redirect, @response.inspect
  end

  test 'user can signup' do
    login_simple_user

    get '/account/plans'
    assert_response :success

    post '/account/plans/megashift/upgrade'
    assert_redirected_to '/account/plans/megashift/upgrade/edit'

    get '/account/plans/megashift/upgrade/edit'
    assert_response :success

    put '/account/plans/megashift/upgrade/edit', :web_user => user_params
    assert_redirected_to '/account/plans/megashift/upgrade/payment_method'

    get '/account/plans/megashift/upgrade/payment_method'
    assert_redirected_to '/account/plans/megashift/upgrade/payment_method/new'

    get '/account/plans/megashift/upgrade/payment_method/new'
    assert_response :success

    #post 'pci' #PCI url
    #assert_redirected_to '/account/upgrade/megashift/new

    get '/account/plans/megashift/upgrade/new'
    assert_response :success

    put '/account/plan', {:id => 'megashift'}
    assert_redirected_to '/account/plan'

    get '/account/plan'
    assert_response :success
  end
end if Aria.available?
