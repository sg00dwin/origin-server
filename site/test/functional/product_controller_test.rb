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
