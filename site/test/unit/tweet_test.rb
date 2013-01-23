require File.expand_path('../../test_helper', __FILE__)

class TweetTest < ActiveSupport::TestCase

  uses_http_mock
  setup{ Rails.cache.clear }
  setup{ ActiveResource::HttpMock.reset! }

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

  def test_tweets
    mock_tweets

    assert t = Tweet.openshift_tweets
    assert_equal 6, t.length
    assert tw = t.first
    assert tw.id.present?
    assert tw.text.present?
    assert_equal 'OpenShift by Red Hat', tw.user.name
  end

  def test_retweets
    mock_tweets

    assert t = Tweet.openshift_retweets
    assert_equal 4, t.length
    assert tw = t.first
    assert tw.id.present?
    assert tw.text.present?
    assert_equal 'OpenShift by Red Hat', tw.user.name
    assert tw.retweeted_status.id.present?
    assert tw.retweeted_status.text.present?
    assert_equal 'Michael McGrath', tw.retweeted_status.user.name

    assert_equal tw.text, tw.text_with_entities.join
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
