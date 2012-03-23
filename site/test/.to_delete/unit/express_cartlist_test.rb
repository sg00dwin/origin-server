require 'test_helper'

class ExpressCartlistTest < ActiveSupport::TestCase

  @@valid_cart_types = ['standalone', 'embedded']
  @@standalone_list =  ['perl-5.10', 'jbossas-7', 'python-2.6', 'ruby-1.8', 'php-5.3', 'diy-0.1', 'jenkins-1.4', 'nodejs-0.6']
  @@embedded_list = ['mysql-5.1']


  #def setup
    #@cartlist = ExpressCartlist.new( 'standalone' )
  #end

  test 'standalone cartlist is correct' do
    cartlist = ExpressCartlist.new 'standalone'
    assert_equal @@standalone_list.sort, cartlist.list.sort
  end

  test 'embedded cartlist is correct' do
    cartlist = ExpressCartlist.new 'embedded'
    assert_equal @@embedded_list.sort, cartlist.list.sort
  end

  #test 'zero exit code creates list' do
    #Rails.logger.debug "in zero_exit_code_creates_list"
    #res = { :exit_code => 0, :data =>  "{ 'carts': [ 'php-5.3',  'ruby-1.8', 'python-2.6',  'perl-5.10' ]}"}
    #json = ActiveSupport::JSON.encode res
    #@cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
    #@cartlist.establish true
    #Rails.logger.debug "List: #{@cartlist.list}"
    #assert @cartlist.list == [ "php-5.3", "ruby-1.8", "python-2.6", "perl-5.10" ]
  #end

  #test 'nonzero exit code triggers error' do
    #Rails.logger.debug "in nonzero exit code triggers error"
    #res = { :exit_code => 1, :result => 'There was an error' }
    #json = ActiveSupport::JSON.encode res
    #@cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
    #@cartlist.establish true
    #Rails.logger.debug "Cartlist errors: #{@cartlist.errors.inspect}"
    #assert @cartlist.errors[:base].include? 'There was an error'
  #end

  #test 'cart type should be present' do
    #@cartlist.cart_type = nil
    #assert !@cartlist.valid?
  #end

  #test 'cart type should be standalone or embedded' do
    #@cartlist.cart_type = 'invalid'
    #assert !@cartlist.valid?
  #end

  #test 'zero exit code creates cache' do
    #Rails.logger.debug "in zero exit code creates cache"
    #res = { :exit_code => 0, :data => "{ 'carts': [ 'test', 'cart', 'list' ]}"}
    #json = ActiveSupport::JSON.encode res

    #@@valid_cart_types.each do |cart_type|
      #@cartlist.cart_type = cart_type
      #@cartlist.expects(:http_post).yields(ActiveSupport::JSON.decode json)
      #@cartlist.establish true
      #cached_list = Rails.cache.read "cartlist_#{cart_type}"
      #assert !cached_list.nil?
    #end
  #end

end
