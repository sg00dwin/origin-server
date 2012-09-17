require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class RescueFromTest < ActionDispatch::IntegrationTest
  def controller_raises(exception)
    with_configured_user
    ProductController.any_instance.expects(:index).raises(exception)
    get '/'
  end
end
