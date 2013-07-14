require File.expand_path('../../test_helper', __FILE__)

class ProductControllerTest < ActionController::TestCase

  def mock_tweets
    api_site = Rails.application.config.twitter_api_site
    api_prefix = Rails.application.config.twitter_api_prefix
    api_endpoint = 'user_timeline.json?screen_name=openshift&count=50&trim_user=false&exclude_replies=true&contributor_details=true&include_rts=true'
    oauth_headers = Tweet.oauth(
      "#{api_site}#{api_prefix}#{api_endpoint}",
      Rails.application.config.twitter_oauth_consumer_key,
      Rails.application.config.twitter_oauth_consumer_secret,
      Rails.application.config.twitter_oauth_token,
      Rails.application.config.twitter_oauth_token_secret)
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get(
        "#{api_prefix}#{api_endpoint}",
        oauth_headers,
        IO.read('test/fixtures/timeline.json'))
    end
  end

  uses_http_mock
  setup{ mock_tweets }

  test 'should be same origin protected' do
    get :index
    assert_redirected_to community_url
    assert_equal 'SAMEORIGIN', @response.to_a[1]['X-Frame-Options'], @response.inspect
  end

  test "should get index unauthorized" do
    get :index
    assert_redirected_to community_url
  end

  test "should get index authorized" do
    get(:index, {}, {:login => "test", :ticket => "test" })
    assert_redirected_to community_url
  end

  test "legacy redirector should redirect" do
    get :legacy_redirect, :route => 'foo'
    assert_redirected_to community_base_url('foo')
  end

  test 'error should render the correct template' do
    get :error

    assert_template 'console/error'
  end

  test 'console_not_found should render the correct template' do
    get :console_not_found

    assert_template 'console/not_found', :layout => 'layouts/console'
  end

  test 'console_error should render the correct template' do
    get :console_error

    assert_template 'console/error', :layout => 'layouts/console'
  end

  [
    :core_error, :core_not_found, :core_unavailable,
    :core_request_denied,
    :core_app_error, :core_app_unavailable, :core_app_installing
  ].each do |sym|
    test "#{sym} should specify the default #{sym} layout" do
      get sym

      assert_template "product/#{sym}"
    end
  end

end

module RestApi
  module Oauth
    module ClassMethods
      private
        def generate_oauth_nonce; '0'; end
        def timestamp; '0'; end
    end
  end
end
