require File.expand_path('../../test_helper', __FILE__)

class TweetTest < ActiveSupport::TestCase

  uses_http_mock
  setup{ Rails.cache.clear }
  setup{ ActiveResource::HttpMock.reset! }

  def mock_tweets
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/1/statuses/retweeted_by_user.json?count=10&include_entities=true&screen_name=openshift', anonymous_json_header, IO.read('test/fixtures/retweets.json'))
      mock.get('/1/statuses/user_timeline/openshift.json?count=10&include_entities=true', anonymous_json_header, IO.read('test/fixtures/openshift_tweets.json'))
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
