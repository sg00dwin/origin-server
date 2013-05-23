require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class RescueFromTest < ActionDispatch::IntegrationTest
  #def controller_raises(exception)
  #  with_configured_user
  #  ProductController.any_instance.expects(:index).raises(exception)
  #  get '/'
  #end
  def controller_raises(exception)
    with_configured_user
    ConsoleIndexController.any_instance.expects(:index).raises(exception)
    with_rescue_from do
      login
      get '/console'
    end
  end

  def default_error_message
    /We appear to be having technical difficulties/i
  end

  def product_controller_raises(exception)
    with_configured_user
    ProductController.any_instance.expects(:index).raises(exception)
    with_rescue_from do
      get '/'
    end
  end

  def test_render_unexpected_error_page
    controller_raises(ActiveResource::ConnectionError.new(nil))
    assert_error_page
  end

  def test_render_console_standard_error_page
    controller_raises(StandardError.new)
    assert_error_page
  end

  def test_render_unexpected_aria_error_page
    product_controller_raises(Aria::Error)
    assert_error_page
  end

  def test_render_unexpected_streamline_error_page
    product_controller_raises(Streamline::Error)
    assert_error_page
  end

  def test_render_standard_error_page
    product_controller_raises(StandardError.new)
    assert_error_page
  end

  def test_render_standard_error_page
    product_controller_raises(Exception.new)
    assert_error_page
  end

  def test_render_server_unavailable_page
    controller_raises(RestApi::ServerUnavailable.new(OpenStruct.new(:code => 503)))
    assert_redirected_to :controller => 'console_index', :action => 'server_unavailable'
  end

  def test_access_denied_results_in_redirect
    product_controller_raises(AccessDeniedException)
  
    assert_response :redirect
  end
end
