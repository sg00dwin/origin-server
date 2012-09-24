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

  def product_controller_raises(exception)
    with_configured_user
    ProductController.any_instance.expects(:index).raises(exception)
    with_rescue_from do
      get '/'
    end
  end

  def test_render_unexpected_error_page
    controller_raises(ActiveResource::ConnectionError.new(nil))

    assert_response :success
    assert_select 'h1', /We appear to be having technical difficulties/

    assert assigns(:reference_id)
    assert_select 'p', /#{assigns(:reference_id)}/
  end

  def test_render_unexpected_site_error_page
    product_controller_raises(ActiveResource::ConnectionError.new(nil))

    assert_response :success
    assert_select 'h1', /We appear to be having technical difficulties/

    assert assigns(:reference_id)
    assert_select 'p', /#{assigns(:reference_id)}/
  end
end
