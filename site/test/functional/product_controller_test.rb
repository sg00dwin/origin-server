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
    assert_response :success
    assert_equal 'SAMEORIGIN', @response.to_a[1]['X-Frame-Options'], @response.inspect
  end

  test "should get index unauthorized" do
    get :index
    assert assigns(:tweets).length > 0
    assert assigns(:retweets).length > 0
    assert_response :success
    assert_select "head title", "OpenShift by Red Hat"
    assert_select "script", :minimum => 1 do |elements|
      assert elements.any?{ |e| e['src'].ends_with?('/status.js?id=outage') }
    end
    assert_select "ul.news.unstyled > li", :minimum => 1
    assert_select "#buzz #buzz-retweets .tweet", :minimum => 1
    assert_select "#buzz #buzz-tweets .tweet", :minimum => 1
  end

  test "should get index authorized" do
    get(:index, {}, {:login => "test", :ticket => "test" })
    assert :success
  end

  test "should be able to fetch tweets" do
    begin 
      assert tweets = Tweet.openshift_tweets
      assert tweets.length > 0

      assert tweets = Tweet.openshift_retweets
      assert tweets.length > 0
    rescue ActiveResource::BadRequest
      omit("Twitter is rejecting requests because of rate limits")
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
