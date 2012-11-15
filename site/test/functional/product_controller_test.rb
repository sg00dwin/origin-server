require File.expand_path('../../test_helper', __FILE__)

class ProductControllerTest < ActionController::TestCase

  def mock_tweets
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/1/statuses/retweeted_by_user.json?count=10&include_entities=true&screen_name=openshift', anonymous_json_header, IO.read('test/fixtures/retweets.json'))
      mock.get('/1/statuses/user_timeline/openshift.json?count=10&include_entities=true', anonymous_json_header, IO.read('test/fixtures/openshift_tweets.json'))
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
