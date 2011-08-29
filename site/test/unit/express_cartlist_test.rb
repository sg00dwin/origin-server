require 'test_helper'

class ExpressCartlistTest < ActiveSupport::TestCase

  @@valid_cart_types = ['standalone', 'embedded']

  def setup
    @cartlist = ExpressCartlist.new( 'standalone' )
    @@valid_cart_types.each do |cart_type|
      File.delete "tmp/#{cart_type}" if File.exists? "tmp/#{cart_type}"
    end
  end

  test 'zero exit code creates list' do
    Rails.logger.debug "in zero_exit_code_creates_list"
    res = { :exit_code => 0, :data =>  "{ 'carts': [ 'php-5.3',  'rack-1.1', 'wsgi-3.2',  'perl-5.10' ]}"}
    json = ActiveSupport::JSON.encode res
    @cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
    @cartlist.establish
    assert @cartlist.list == [ "php-5.3", "rack-1.1", "wsgi-3.2", "perl-5.10" ]
  end
  
  test 'nonzero exit code triggers error' do
    Rails.logger.debug "in nonzero exit code triggers error"
    res = { :exit_code => 1, :result => 'There was an error' }
    json = ActiveSupport::JSON.encode res
    @cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
    @cartlist.establish
    Rails.logger.debug "Cartlist errors: #{@cartlist.errors.inspect}"
    assert @cartlist.errors[:base].include? 'There was an error'
  end
  
  test 'cart type should be present' do
    @cartlist.cart_type = nil
    assert !@cartlist.valid?
  end

  test 'cart type should be standalone or embedded' do
    @cartlist.cart_type = 'invalid'
    assert !@cartlist.valid?
  end
  
  test 'zero exit code creates cache' do
    Rails.logger.debug "in zero exit code creates cache"
    res = { :exit_code => 0, :data => "{ 'carts': [ 'test', 'cart', 'list' ]}"}
    json = ActiveSupport::JSON.encode res
                                                
    @@valid_cart_types.each do |cart_type|
      @cartlist.cart_type = cart_type
      @cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
      @cartlist.establish
      
      assert File.exists? "tmp/#{cart_type}"
    end
  end
  
  test 'cache timeout creates new cache' do
    @cartlist.expects('refresh_cache?').returns true
    @cartlist.expects(:cache_list)
    @cartlist.set_list
  end
  
  test 'cached list is used if cache not timed out' do
    @cartlist.establish
    @cartlist.expects('refresh_cache?').returns false
    @cartlist.expects(:get_cached_list)
    @cartlist.set_list
  end
  
end
