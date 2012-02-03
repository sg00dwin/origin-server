require 'active_support/core_ext/hash/conversions'
require 'active_resource'

class UserAwareConnection < ActiveResource::Connection
  attr :as

  def initialize(url, format, as)
    super url, format
    @as = as
    @user = @as.rhlogin if @as.rhlogin
  end

  def authorization_header(http_method, uri)
    headers = super
    if @as.respond_to? :authorization_cookie and @as.authorization_cookie
      (headers['Cookie'] ||= '') << @as.authorization_cookie.to_s
    end
    if @as.rhlogin
      headers['X-rhlogin'] = @as.rhlogin
    end
    puts "headers #{headers.inspect}"
    headers
  end
end

class OpenshiftResource < ActiveResource::Base
  self.ssl_options = { :verify_mode => OpenSSL::SSL::VERIFY_NONE }

  self.site = if defined?(Rails) && Rails.configuration.express_api_url
    Rails.configuration.express_api_url + '/broker/rest'
  else
    'http://localhost'
  end

  # Track persistence state, merged from 
  # https://github.com/railsjedi/rails/commit/9333e0de7d1b8f63b19c99d21f5f65fef0ce38c3
  #
  def initialize(attributes = {}, persisted=false)
    @persisted = persisted
    super attributes
  end

  def instantiate_record(record, prefix_options = {})
    new(record, true).tap do |resource|
      resource.prefix_options = prefix_options
    end
  end

  def new?
    !persisted?
  end

  def persisted?
    @persisted
  end

  class << self

    def load_attributes_from_response(response)
      if response['Content-Length'] != "0" && response.body.strip.size > 0
        load(update_root(self.class.format.decode(response.body)))
        @persisted = true
      end
    end

    def update_root(obj)
      puts "Root #{obj.inspect}"
      obj
    end

    #
    # has_many / belongs_to placeholders
    #
    def has_many(sym)
    end
    def belongs_to(sym)
      prefix = "#{site.path}#{sym.to_s}"
    end

    #
    # Override methods from ActiveResource to make them contextual connection
    # aware
    #
    def delete(id, options = {})
      connection(options).delete(element_path(id, options)) #changed
    end

    #
    # Make connection specific to the instance, and aware of user context
    #
    def connection(options = {}, refresh = false)
      if options[:as]
        puts 'user aware connection'
        update_connection(UserAwareConnection.new(site, format, options[:as]))
      elsif defined?(@connection) || superclass == Object
        puts 'normal connection'
        @connection = update_connection(ActiveResource::Connection.new(site, format)) if @connection.nil? || refresh
        @connection
      else
        superclass.connection
      end
    end

    private
      def update_connection(connection)
        connection.proxy = proxy if proxy
        connection.user = user if user
        connection.password = password if password
        connection.auth_type = auth_type if auth_type
        connection.timeout = timeout if timeout
        connection.ssl_options = ssl_options if ssl_options
        connection
      end

      def find_every(options)
        begin
          case from = options[:from]
          when Symbol
            instantiate_collection(get(from, options[:params]))
          when String
            path = "#{from}#{query_string(options[:params])}"
            instantiate_collection(format.decode(connection(options).get(path, headers).body) || []) #changed
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            instantiate_collection(format.decode(connection(options).get(path, headers).body) || [], prefix_options ) #changed
          end
        rescue ActiveResource::ResourceNotFound
          # Swallowing ResourceNotFound exceptions and return nil - as per
          # ActiveRecord.
          nil
        end
    end
  end

  def as=(as)
    @connection = nil
    @as = as
  end

  protected
    # Context of calls made to the object
    def as
      return @as
    end

    def connection(refresh = false)
      puts "as=#{@as}"
      @connection = self.class.connection({:as => @as}) if refresh || @connection.nil?
      #raise "No valid user context to run in, set :as" if as.nil?
      #connection.authorization_cookie = as.streamline_cookie
    end
end

class User < OpenshiftResource
  has_many :ssh_key
end

class SshKey < OpenshiftResource
  self.primary_key = 'name'
  self.element_name = 'key'

  belongs_to :user

  schema do
    string :name, :key_type, :value
  end

  validates :name, :length => {:maximum => 50},
                   :presence => true,
                   :allow_blank => false
  validates_format_of :key_type,
                      :with => /^ssh-(rsa|dss)$/,
                      :message => "is not ssh-rsa or ssh-dss"
  validates :value, :length => {:maximum => 2048},
                    :presence => true,
                    :allow_blank => false

  def to_param
    name
  end
end


if __FILE__==$0
  #require 'test/unit/ui/console/testrunner'

  class TestCookie
    def initialize(name, values)
      @name = name
      @values = values
    end
    def to_s
      "#{@name}=#{@values[:value]}"
    end
  end

  class TestUser
    attr :rhlogin
    def initialize(rhlogin)
      @rhlogin = rhlogin
    end
    def authorization_cookie
      TestCookie.new :rh_sso, {:value => '1234'}
    end
  end

  SshKey.site = 'https://ec2-184-73-148-206.compute-1.amazonaws.com/broker/rest'
  SshKey.prefix='/broker/rest/user/'
  user = TestUser.new 'test1@test1.com'
  begin
    key = SshKey.new :name => 'a', :value => 'b', :key_type => 'ssh-rsa'
    key.as = user
    key.save
    puts key.inspect
    SshKey.find(:all, :as => user).inspect
  rescue ActiveResource::ConnectionError => e
    puts "#{e.response}=#{e.response.body}\n#{e.response.inspect}"
    raise 
  end
  puts "-------------------\n"

  if true

  ActiveSupport::XmlMini.backend = 'REXML'
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get '/user/keys.xml', {}, [{:type => :rsa, :name => 'test1', :value => '1234' }].to_xml(:root => 'ssh_key')
    mock.post '/user/keys.xml', {}, {:type => :rsa, :name => 'test2', :value => '1234_2' }.to_xml(:root => 'ssh_key')
    mock.delete '/user/keys/test1.xml', {}, {}
  end

  require 'test/unit'
  require 'mocha'
  class OpenshiftResourceTest < Test::Unit::TestCase
    def test_get_ssh_keys
      items = SshKey.find :all
      assert_equal 1, items.length
    end

    def test_post_ssh_key
      key = SshKey.new :key_type => 'ssh-rsa', :name => 'test2', :value => '1234_2'
      assert key.save
    end

    def test_ssh_key_validation
      key = SshKey.new :key_type => 'ssh-rsa', :name => 'test2'
      assert !key.save
      assert_equal 1, key.errors[:value].length

      key.value = ''
      assert !key.save
      assert_equal 1, key.errors[:value].length

      key.value = 'a'
      assert key.save
      assert key.errors.empty?
    end

    def test_ssh_key_delete
      items = SshKey.find :all
      assert items[0].destroy
    end

    def test_agnostic_connection
      assert OpenshiftResource.connection.is_a? ActiveResource::Connection
      assert OpenshiftResource.connection({:as => {}}).is_a? UserAwareConnection
    end

    def test_ssh_key_with_user
      items = SshKey.find :all, :as => {:login => 'test1', :password => 'password'}
      assert_equal 1, items.length
    end

    def test_create_cookie
      connection = UserAwareConnection.new 'http://localhost', :xml, TestUser.new
      headers = connection.authorization_header(:post, '/something')
      assert_equal 'rh_sso=1234', headers['Cookie']
    end
  end
  end

  #Test::Unit::UI::Console::TestRunner.run(OpenshiftResourceTest)
end
