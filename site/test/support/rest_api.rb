require 'mocha'
require 'openshift'
require 'streamline'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  def setup_api
    host = ENV['LIBRA_HOST'] || 'localhost'
    RestApi::Base.site = "https://#{host}/broker/rest"
    RestApi::Base.prefix='/broker/rest/'
  end
  def setup_user(unique=false)
    set_user(WebUser.new :email_address=>"app_test1#{unique ? uuid : ''}@test1.com", :rhlogin=>"app_test1#{unique ? uuid : ''}@test1.com", :ticket => '1')
  end
  def set_user(user)
    session[:login] = user.login
    session[:user] = user
    session[:ticket] = user.ticket
    @request.cookies['rh_sso'] = user.ticket
    @request.env['HTTPS'] = 'on'
    @user = user
  end

  def auth_headers
   {'Cookie' => "rh_sso=#{@user.ticket}", 'Authorization' => "Basic #{::Base64.encode64s("#{@user.login}:#{@user.password}")}"}
  end

  # Create a new, unique user
  def unique_user
    id = new_uuid
    WebUser.new :email_address=>"app_test1#{id}@test1.com", :rhlogin=>"app_test1#{id}@test1.com"
  end
  def uuid
    @ts ||= new_uuid
  end
  def new_uuid
    "#{Time.now.to_i}#{gen_small_uuid[0,6]}"
  end

  def set_domain(domain)
    @domain = domain
  end

  def setup_domain
    domain = Domain.new :name => "#{uuid}", :as => @user
    unless domain.save
      puts domain.errors.inspect
      fail 'Unable to create the initial domain, test cannot be run'
    end
    set_domain(domain)
  end

  def cleanup_domain
    # skip cleanup for speed
    unless @with_unique_user
      @domain.destroy_recursive if @domain
    end
  end

  #
  # Create and authenticate a user that is unique per test case,
  # without any session information.
  #
  def with_simple_unique_user
    setup_api
    @user = RestApi::Authorization.new "rest-api-test-#{uuid}@test1.com"
    @with_unique_user = true
  end

  #
  # Create and authenticate a user that is unique per test case
  #
  def with_unique_user
    setup_api
    uuid
    setup_user(true)
    @with_unique_user = true
  end

  #
  # Create and authenticate a user that is unique per test case and
  # create an initial domain for that user.
  #
  def with_unique_domain
    with_unique_user
    setup_domain
  end

  #
  # Create a domain and user that are shared by all tests in the test suite, 
  # and is only destroyed at the very end of the suite.  If you do not clean
  # up after creating applications you will hit the application limit for
  # this user.
  #
  def with_domain
    setup_api
    setup_user
    once :domain do
      domain = Domain.first :as => @user
      domain.destroy_recursive if domain
      @@domain = setup_domain
      unless @with_unique_user
        lambda do
          begin
            @@domain.destroy_recursive
          rescue ActiveResource::ResourceNotFound
          end
        end
      end
    end
    @domain = @@domain
  end

  def setup_from_app(app)
    set_domain Domain.new({:id => app.domain_id, :as => app.as}, true)
    set_user app.as
    app
  end

  def self.api_cache
    @@cache ||= {}
  end

  def api_fetch(name, &block)
    varname = "@#{name}_cached"
    instance_variable_get(varname) || begin
      created = if cached = self.class.api_cache[name]
          block.call(cached) || cached
        else
          self.class.api_cache[name] = block.call(nil)
        end
      instance_variable_set(varname, created)
    end
  end

  def use_app(symbol, &block)
    api_fetch(symbol) do |cached|
      if cached
        setup_from_app(cached)
      else
        with_unique_domain
        app = yield block if block_given?
        app ||= Application.new :name => uuid
        app.as ||= @user
        app.domain_id ||= @domain.id
        app.save!
        app
      end
    end
  end

  def with_app
    use_app(:readable_app) { Application.new({:name => "cart#{uuid}", :cartridge => 'ruby-1.8'}) }
  end

  def with_scalable_app
    use_app(:scalable_app) { Application.new({:name => "cart#{uuid}", :cartridge => 'ruby-1.8', :scale => 'true'}) }
  end


  def assert_attr_equal(o1, o2)
    unless o1 == o2
      assert o1, "#{o1} is not equal to #{o2}"
      assert o2, "#{o1} is not equal to #{o2}"
      if o1.is_a? Array and o2.is_a? Array
        assert o1.length == o2.length, "Array 1 length #{o1.length} is not array 2 length #{o2.length}"
        o1.each_with_index { |o,i| assert_attr_equal(o, o2[i]) }
      else
        assert_equal o1.attributes, o2.attributes, "Attributes do not match"
      end
    end
  end
end
