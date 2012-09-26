require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class AssetsTest

  test 'retrieve console.css' do
    get '/assets/site.css'
    assert_response :success
    assert_equal 'text/css', @response.content_type
    assert @response.body.length > 20*1024
  end

  test 'retrieve site.css' do
    get '/assets/site.css'
    assert_response :success
    assert_equal 'text/css', @response.content_type
    assert @response.body.length > 20*1024
  end
end
