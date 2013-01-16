require File.expand_path('../../test_helper', __FILE__)

class TweetTest < ActiveSupport::TestCase

  uses_http_mock
  setup{ Rails.cache.clear }
  setup{ ActiveResource::HttpMock.reset! }

  def mock_tweets
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get(
        '/1.1/statuses/user_timeline.json?screen_name=openshift&count=50&trim_user=false&exclude_replies=true&contributor_details=true&include_rts=true', 
        anonymous_json_header, 
        IO.read('test/fixtures/timeline.json'))
    end
  end

  def mock_oauth
    Tweet.expects(:oauth).at_least(0).returns(nil)
  end

  def test_tweets
    mock_oauth
    mock_tweets

    assert t = Tweet.openshift_tweets
    assert_equal 6, t.length
    assert tw = t.first
    assert tw.id.present?
    assert tw.text.present?
    assert_equal 'OpenShift by Red Hat', tw.user.name
  end

  def test_retweets
    mock_oauth
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
