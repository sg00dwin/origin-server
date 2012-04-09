require 'test_helper'

class RestApiTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    #
    # Integration tests are designed to run against the 
    # production OpenShift service by default.  To change
    # this, update ~/.openshift/api.yaml to point to a
    # different server.
    #
    config = RestApi::Configuration.activate(:external)
    if config[:authorization] == :passthrough
      puts "Passthrough"
      puts config.pretty_inspect
      @user = RestApi::Authorization.new config[:login], nil, config[:password]
      puts @user.pretty_inspect
    end

    Domain.any_instance.expects(:check_duplicate_domain).returns(false)

    with_unique_user
  end
  def teardown
    @domain.destroy_recursive if @domain
  end

  #
  # Integration tests have no session, so we skip that setup
  #
  def with_unique_user
    setup_api
    @user ||= RestApi::Authorization.new "rest-api-test-#{uuid}@test1.com"
  end

  def test_key_get_all
    items = Key.find :all, :as => @user
    assert_equal 0, items.length
  end

  def test_key_first
    assert_equal Key.first(:as => @user), Key.find(:all, :as => @user)[0]
  end

  def test_key_create
    items = Key.find :all, :as => @user

    orig_num_keys = items.length

    key = Key.new :type => 'ssh-rsa', :name => "test#{@ts}", :content => @ts, :as => @user
    assert key.save

    items = Key.find :all, :as => @user
    assert_equal orig_num_keys + 1, items.length
  end

  def test_invalid_key_create
    items = Key.find :all, :as => @user

    orig_num_keys = items.length
    begin
      key = Key.new :type => 'ssh-rsa', :name => "invalid_name#{@ts}", :content => @ts, :as => @user
      key.save
      fail
    rescue
    end

    items = Key.find :all, :as => @user
    assert_equal orig_num_keys, items.length
  end

  def test_key_server_validation
    key = Key.new :as => @user
    assert !key.save(:validate => false) # don't check client validations
    assert !key.errors.empty?
    assert_equal ['Key name is required and cannot be blank.'], key.errors[:name]
    assert_equal ['Key content is required and cannot be blank.'], key.errors[:content]
    assert_equal ['Type is required and cannot be blank.'], key.errors[:type]
  end

  def test_key_delete
    items = Key.find :all, :as => @user

    orig_num_keys = items.length

    key = Key.new :type => 'ssh-rsa', :name => "test#{@ts}", :content => @ts, :as => @user
    assert key.save

    items = Key.find :all, :as => @user
    assert_equal orig_num_keys + 1, items.length

    assert items[items.length-1].destroy

    items = Key.find :all, :as => @user
    assert_equal orig_num_keys, items.length
  end

  def test_user_get
    user = User.find :one, :as => @user
    assert user
    assert_equal @user.login, user.login
  end

  def test_key_create_without_domain
    domain = Domain.first(:as => @user)
    domain.destroy_recursive if domain

    key = Key.new :raw_content => 'ssh-rsa key', :name => 'default', :as => @user
    assert key.save
    assert key.errors.empty?
  end

  def test_key_create
    key = Key.new :raw_content => 'ssh-rsa key', :name => 'default', :as => @user
    assert key.save
    assert key.errors.empty?

    key.destroy
    assert_raise ActiveResource::ResourceNotFound do
      Key.find 'default', :as => @user
    end
  end

  def test_key_list
    keys = Key.find :all, :as => @user
    assert_equal [], keys
    assert_nil Key.first :as => @user

    key = Key.new :raw_content => 'ssh-rsa key', :name => 'default', :as => @user
    assert key.save
    assert key.errors.empty?
    key.messages = nil
    key.id = nil

    keys = Key.find :all, :as => @user
    assert_equal 'ssh-rsa', keys[0].type
    assert_equal 'key', keys[0].content
    assert_equal 'default', keys[0].name
    assert_equal [key], keys

    key_new = Key.find 'default', :as => @user
    assert_equal key, key_new
  end

  def test_domains_get
    setup_domain
    domains = Domain.find :all, :as => @user
    assert_equal 1, domains.length
    assert_equal "#{@ts}", domains[0].name
  end

  def test_domains_first
    setup_domain
    domain = Domain.first(:as => @user)
    assert_equal "#{@ts}", domain.name
  end

  def test_domain_exists_error
    setup_domain
    domain = Domain.first(:as => @user)
    domain2 = Domain.new :name => domain.name, :as => @user
    assert !domain2.save
    assert domain2.errors[:name].is_a? Array
    assert domain2.errors[:name][0].is_a? String
    assert domain2.errors[:name][0].include?('Name'), domain2.errors[:name][0]
  end

  def test_domains_update
    setup_domain
    domains = Domain.find :all, :as => @user
    assert_equal 1, domains.length
    assert_equal "#{@ts}", domains[0].name

    d = domains[0]
    assert !d.changed?
    assert_equal "#{@ts}", d.id

    # change name twice to make sure id doesn't change
    d.name = "notsaved"
    assert d.changed?
    assert_equal "#{@ts}", d.to_param
    d.name = "#{@ts.reverse}"
    assert_equal "#{@ts}", d.to_param

    assert d.save, d.errors.inspect
    assert !d.changed?
    # make sure the param value == the current name
    assert_equal "#{@ts.reverse}", d.to_param

    domains = Domain.find :all, :as => @user
    assert_equal 1, domains.length
    assert_equal "#{@ts.reverse}", domains[0].name

    #cleanup
    domains.each {|d| d.destroy_recursive}
    @domain = nil
  end

  def test_domain_delete
    RestApi.debug do
      setup_domain
    end
    # we can only have one domain so delete it and restore it
    items = Domain.find :all, :as => @user
    domain = items[0]
    name = domain.name

    orig_num_domains = items.length

    assert domain.destroy

    items = Domain.find :all, :as => @user
    assert_equal orig_num_domains - 1, items.length

    @domain = nil # don't need to clear the first domain now
  end

  def test_domains_applications
    setup_domain
    domain = Domain.first(:as => @user)

    app1 = Application.new :name => 'app1', :cartridge => 'php-5.3', :as => @user
    app2 = Application.new :name => 'app2', :cartridge => 'php-5.3', :as => @user

    app1.domain = domain
    app2.domain = domain

    assert app1.save, app1.errors.inspect
    assert app2.save, app2.errors.inspect

    apps = domain.applications
    assert_equal 2, apps.length
    assert_equal 'app1', apps[0].name
    assert_equal 'app2', apps[1].name

    # test find_application
    app1 = domain.find_application('app1')
    app2 = domain.find_application('app2')
    assert_equal apps[0], app1
    assert_equal apps[1], app2
  end

  def test_domains_applications_delete
    setup_domain
    domain = Domain.first(:as => @user)

    items = domain.applications
    orig_num_apps = items.length

    app_delete = Application.new :name => 'deleteme', :cartridge => 'php-5.3', :as => @user
    app_delete.domain = domain

    assert app_delete.save

    domain.reload

    items = domain.applications
    assert_equal orig_num_apps + 1, items.length

    app_delete = domain.find_application('deleteme')
    assert app_delete.destroy

    domain.reload

    items = domain.applications
    assert_equal orig_num_apps, items.length
  end

  def test_domain_reload
    setup_domain
    domain = Domain.first :as => @user
    oldname = domain.name
    domain.name = 'foo'
    assert_equal 'foo', domain.name
    domain.reload
    assert_equal oldname, domain.name
  end

  def test_domain_find_throws
    assert_raise ActiveResource::ResourceNotFound do
      Domain.find 'invalid_name', :as => @user
    end
  end
end
