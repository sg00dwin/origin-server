
require File.expand_path('../../test_helper', __FILE__)

class TwitterControllerTest < ActionController::TestCase

  uses_http_mock
  setup { Rails.cache.clear }

  def twitter_url
    '/1.1/statuses/user_timeline.json?screen_name=openshift&count=50&trim_user=false&exclude_replies=true&contributor_details=true&include_rts=true'
  end

  def oauth_headers
    Tweet.oauth "#{Tweet.site}#{twitter_url}", Tweet.oauth_consumer_key, Tweet.oauth_consumer_secret, Tweet.oauth_token, Tweet.oauth_token_secret
  end

  test 'should get tweets' do

    Tweet.stub :generate_oauth_nonce, '12345678' do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get(twitter_url, anonymous_json_header.merge(oauth_headers), IO.read('test/fixtures/timeline.json'))
      end

      assert get(:latest_tweets).body.include? 'New Blog: There were some environment variable changes in last week\'s #mongodb upgrade'
    end

  end

  test 'should get retweets' do

    Tweet.stub :generate_oauth_nonce, '12345678' do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get(twitter_url, anonymous_json_header.merge(oauth_headers), IO.read('test/fixtures/timeline.json'))
      end

      assert get(:latest_retweets).body.include? 'OpenShift as a Cloud back-end for your Mobile Apps'
    end

  end

  test 'should return an empty list when fetching tweets returns a 500' do

    Tweet.stub :generate_oauth_nonce, '12345678' do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get(twitter_url, anonymous_json_header.merge(oauth_headers), 'Error', 500)
      end

      assert_equal '',  get(:latest_tweets).body
    end
  end

  test 'should return empty list when fetching retweets returns a 500' do

    Tweet.stub :generate_oauth_nonce, '12345678' do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get(twitter_url, anonymous_json_header.merge(oauth_headers), 'Error', 500)
      end

      assert_equal '',  get(:latest_retweets).body
    end
  end
end
