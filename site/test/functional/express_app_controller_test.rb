require 'test_helper'

class ExpressAppControllerTest < ActionController::TestCase
  
  test 'should create new app' do
    post(:create, {:app_name => 'test', :cartridge => 'php-5.3'})
    Rails.logger.debug "Create new app - assigns: #{assigns.inspect}"
    Rails.logger.debug "app: #{assigns['@app'].inspect}"
    assert assigns['@app'].valid?
    assert !assigns['@app'].health_path.blank?
  end
  
  test 'should check new app health' do
    post(:create, {:app_name => 'test', :cartridge => 'php-5.3'})
    Rails.logger.debug "Check app health - assigns: #{assigns.inspect}"
    Rails.logger.debug "app: #{assigns['@app'].inspect}"
    assert assigns['@message_type'] == :success
  end

end
