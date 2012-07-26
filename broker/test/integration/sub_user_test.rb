require 'test_helper'

class SubUserTest < ActionDispatch::IntegrationTest
  def setup
    @random = rand(1000000)

    @username = "parent#{@random}"
    @headers = {}
    @headers["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("#{@username}:password")
    @headers["Accept"] = "application/json"
  end

  def test_normal_auth_success
    get "rest/domains.json", nil, @headers
    assert_equal 200, status
  end

  def test_subaccount_role_failure_parent_user_missing
    @headers["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers
    assert_equal 401, status
  end

  def test_subaccount_role_failure
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    @headers["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers
    assert_equal 401, status
  end

  def test_subaccount_role_success
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    `rhc-admin-ctl-user -l #{@username} --allowsubaccounts true`

    @headers["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers
    assert_equal 200, status
  end

  def test_access_someone_elses_subaccount
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    @headers2 = @headers.clone
    @headers2["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("#{@username}x:password")
    get "rest/domains.json", nil, @headers2
    assert_equal 200, status

    `rhc-admin-ctl-user -l #{@username} --allowsubaccounts true`
    `rhc-admin-ctl-user -l #{@username}x --allowsubaccounts true`

    @headers["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    @headers2["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers2
    assert_equal 401, status
  end

  def test_c9_user_gear_setting
    Rails.configuration.cloud9 = {:user_login => @username,
                                  :capabilities => {
                                    'gear_sizes' => ["c9"],
                                    'inherit_on_subaccounts' => ["gear_sizes"]
                                  }}
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    `rhc-admin-ctl-user -l #{@username} --allowsubaccounts true`

    @headers["X-Impersonate-User"] = "subuser#{@random}"
    get "rest/domains.json", nil, @headers
    assert_equal 200, status

    subuser = CloudUser.find "subuser#{@random}"
    assert_equal 1, subuser.capabilities["gear_sizes"].size
    assert_equal "c9", subuser.capabilities["gear_sizes"][0]
  end

  def teardown
  end
end

