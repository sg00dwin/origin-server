require 'test_helper'

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
  
  test 'get_product returns flex when controller name contains flex' do
    controller_name = 'flex_test'
    action_name = 'test'
    assert_equal 'flex', get_product(controller_name, action_name)
  end
  
  test 'get_product returns flex when action name contains flex' do
    controller_name = 'flex'
    action_name = 'test_flex'
    assert_equal 'flex', get_product(controller_name, action_name)
  end
  
  test 'get_product returns power when controller name contains power' do
    controller_name = 'power_test'
    action_name = 'test'
    assert_equal 'power', get_product(controller_name, action_name)
  end
  
  test 'get_product returns power when action name contains power' do
    controller_name = 'test'
    action_name = 'test_power'
    assert_equal 'power', get_product(controller_name, action_name)
  end
  
  test 'get_product returns empty string when neither controller nor action contains a product name' do
    controller_name = 'test'
    action_name = 'test'
    assert_equal '', get_product(controller_name, action_name)
  end

end
