require 'test_helper'

class ExpressAppTest < ActiveSupport::TestCase

  def setup
    @app = ExpressApp.new :app_name => 'test', :cartridge => 'php-5.3'
  end

  test 'app name should be present' do
    @app.app_name = nil
    assert !@app.valid?
  end
  
  test 'app name should not be in blacklist' do
    @app.app_name = 'redhat'
    assert !@app.valid?
  end
  
  test 'app name should not be more than 16 characters' do
    @app.app_name = 'thisisaverylongappname'
    assert !@app.valid?
  end
  
  test 'app name should be alphanumeric' do
    @app.app_name = 'this_is_an_invalid_app_name'
    assert !@app.valid?
  end
  
  test 'cartridge should be present' do
    @app.cartridge = nil
    assert !@app.valid?
  end
  
  test 'cartridge list should be present' do
    @app.expects(:get_cartlist).returns(nil)
    @app.set_cartlist
    assert !@app.valid?
  end
  
  test 'cartridge should be a member of the cartridge list' do
    test_cartlist = ['test']
    @app.expects(:get_cartlist).returns(test_cartlist)
    @app.set_cartlist
    @app.cartridge = 'invalid'
    assert !@app.valid?
  end
  
  test 'successful app configuration sets health path' do
    success = {:exit_code => 0, :data => "{'health_check_path' : 'health'}"}
    res = ActiveSupport::JSON.encode success
    @app.expects(:http_post).yields(ActiveSupport::JSON.decode res)
    @app.configure
    assert @app.health_path == 'health'
  end
  
  test 'failed app configuration sets error' do
    fail = {:exit_code => 100, :result => "There has been an error"}
    res = ActiveSupport::JSON.encode fail
    @app.expects(:http_post).yields(ActiveSupport::JSON.decode res)
    @app.configure
    assert @app.errors[:base].include? "There has been an error"
  end

end
