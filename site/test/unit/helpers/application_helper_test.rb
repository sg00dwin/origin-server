require File.expand_path('../../../test_helper', __FILE__)

class ApplicationHelperTest < ActionView::TestCase
  
  test 'get_product returns express when action name contains express' do
    controller_name = 'test'
    action_name = 'express_test'
    assert_equal 'express', get_product(controller_name, action_name)
  end
  
  test 'get_product returns express when controller name contains express' do
    controller_name = 'express_test'
    action_name = 'test'
    assert_equal 'express', get_product(controller_name, action_name)
  end
  
end
