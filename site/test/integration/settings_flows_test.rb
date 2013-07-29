require File.expand_path('../../test_helper', __FILE__)

class SettingsFlowsTest < ActionDispatch::IntegrationTest

  def setup
    https!
    open_session
  end

  def simple_user
    @simple_user ||= {:web_user => {:rhlogin => uuid, :password => 'password'}}
  end

  def login_simple_user
    post login_path, simple_user
    assert_response :redirect, @response.inspect
    simple_user
  end

  test 'user can create key' do
    user = login_simple_user

    get settings_path
    assert_response :success

    method, action, values = extract_form('form#new_key')
    assert_equal 'post', method
    assert_equal keys_path, action

    post keys_path, values.merge!({:key => {:raw_content =>"ssh-dss atestkey"}})
    assert_redirected_to settings_path

    follow_redirect!
    assert_select 'td', 'atestkey'
  end

  test 'user can create domain' do
    user = login_simple_user

    get settings_path
    assert_response :success

    method, action, values = extract_form('form#new_domain')
    assert_equal 'post', method
    assert_equal domain_path, action

    name = uuid
    post domain_path, values.merge!({:domain => {:id => name}})
    assert_redirected_to settings_path

    follow_redirect!
    assert_select '.namespace', name
    assert_select '.well', %r(http://applicationname)
  end
end

