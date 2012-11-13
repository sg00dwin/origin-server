require File.expand_path('../../test_helper', __FILE__)

class ProductControllerTest < ActionController::TestCase

  test 'should be same origin protected' do
    get :index
    assert_response :success
    assert_equal 'SAMEORIGIN', @response.to_a[1]['X-Frame-Options'], @response.inspect
  end

  test "should get index unauthorized" do
    get :index
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
end
