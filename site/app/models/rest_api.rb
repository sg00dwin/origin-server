require 'active_support/core_ext/hash/conversions'
require 'active_resource'

class RestApi < ActiveResource::Base

  class MissingUserContextError < StandardError
  end

  class UserAwareConnection < ActiveResource::Connection
    attr :as

    def initialize(url, format, as)
      super url, format
      @as = as
      @user = @as.login if @as.respond_to? :login
    end

    def authorization_header(http_method, uri)
      headers = super
      if @as.respond_to? :authorization_cookie and @as.authorization_cookie
        (headers['Cookie'] ||= '') << @as.authorization_cookie.to_s
      end
      headers
    end

    #
    # Changes made in commit https://github.com/rails/rails/commit/51f1f550dab47c6ec3dcdba7b153258e2a0feb69#activeresource/lib/active_resource/base.rb
    # make GET consistent with other verbs (return response)
    #
    def get(path, headers = {})
      with_auth { request(:get, path, build_request_headers(headers, :get, self.site.merge(path))) } #changed, remove .body at end, removed format decode
    end
  end

  self.ssl_options = { :verify_mode => OpenSSL::SSL::VERIFY_NONE }
  self.timeout = 3

  self.site = if defined?(Rails) && Rails.configuration.express_api_url
    Rails.configuration.express_api_url + '/broker/rest'
  else
    'http://localhost'
  end


  # 
  # Track persistence state, merged from 
  # https://github.com/railsjedi/rails/commit/9333e0de7d1b8f63b19c99d21f5f65fef0ce38c3
  #
  def initialize(attributes = {}, persisted=false)
    @persisted = persisted
    @as = attributes[:as]
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
  end

  # 
  # singleton support as https://rails.lighthouseapp.com/projects/8994/tickets/4348-supporting-singleton-resources-in-activeresource
  #
  class << self
    def singleton
      @singleton = true
    end
    def singleton?
      @singleton if defined? @singleton
    end

    attr_accessor_with_default(:collection_name) do
      if singleton?
        element_name
      else 
        ActiveSupport::Inflector.pluralize(element_name)
      end
    end

    def element_path(id = nil, prefix_options = {}, query_options = nil) #changed
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      #"#{prefix(prefix_options)}#{collection_name}/#{URI.escape id.to_s}.#{format.extension}#{query_string(query_options)}"
      #begin changes
      path = "#{prefix(prefix_options)}#{collection_name}"
      unless singleton?
        raise ArgumentError, 'id is required for non-singleton resources' if id.nil?
        path << "/#{URI.escape id.to_s}"
      end
      path << ".#{format.extension}#{query_string(query_options)}"
    end

    def find(*arguments)
      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}

      scope = :one if scope.nil? && singleton? # added

      case scope
      when :all   then find_every(options)
      when :first then find_every(options).first
      when :last  then find_every(options).last
      when :one   then find_one(options)
      else             find_single(scope, options)
      end
    end

    def find_one(options)
      as = options[:as] # for user context support

      case from = options[:from]
      when Symbol
        instantiate_record(get(from, options[:params]))
      when String
        path = "#{from}#{query_string(options[:params])}"
        instantiate_record(format.decode(connection(options).get(path, headers).body), as) #changed
      when nil #begin add
        prefix_options, query_options = split_options(options[:params])
        path = element_path(nil, prefix_options, query_options)
        instantiate_record(format.decode(connection(options).get(path, headers).body), as) #end add
      end
    end
  end

  #
  # has_many / belongs_to placeholders
  #
  class << self
    def has_many(sym)
    end
    def belongs_to(sym)
      prefix = "#{site.path}#{sym.to_s}"
    end
  end

  # 
  # Experimentation with form conversion, likely to be unnecessary
  #
  def to_json(*opt)
    respond_to?(:serialize) ? serialize.to_json(*opt) : super(*opt)
  end
  def to_xml(*opt)
    respond_to?(:serialize) ? serialize.to_xml(*opt) : super(*opt)
  end
  def to_form(*opt)
    (respond_to?(:serialize) ? serialize(*opt) : @attributes).to_param
  end

  #
  # Override methods from ActiveResource to make them contextual connection
  # aware
  #
  class << self
    def delete(id, options = {})
      connection(options).delete(element_path(id, options)) #changed
    end

    #
    # Make connection specific to the instance, and aware of user context
    #
    def connection(options = {}, refresh = false)
      if options[:as]
        update_connection(UserAwareConnection.new(site, format, options[:as]))
      else
        raise MissingUserContextError
      end
      #elsif defined?(@connection) || superclass == Object
      #  #'Accessing RestApi without a user object'
      #  @connection = update_connection(ActiveResource::Connection.new(site, format)) if @connection.nil? || refresh
      #  @connection
      #else
      #  superclass.connection
      #end
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

      def find_single(scope, options)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        instantiate_record(format.decode(connection.get(path, headers).body), options[:as], prefix_options) #changed
      end

      def find_every(options)
        begin
          as = options[:as]
          case from = options[:from]
          when Symbol
            instantiate_collection(get(from, options[:params]), as) #changed
          when String
            path = "#{from}#{query_string(options[:params])}"
            instantiate_collection(format.decode(connection(options).get(path, headers).body) || [], as) #changed
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            instantiate_collection(format.decode(connection(options).get(path, headers).body) || [], as, prefix_options ) #changed
          end
        rescue ActiveResource::ResourceNotFound
          # Swallowing ResourceNotFound exceptions and return nil - as per
          # ActiveRecord.
          nil
        end
      end
      
      def instantiate_collection(collection, as, prefix_options = {})
        collection.collect! { |record| instantiate_record(record, as, prefix_options) }
      end

      def instantiate_record(record, as, prefix_options = {})
        new(record).tap do |resource|
          resource.prefix_options = prefix_options
          resource.as = as
        end
      end
  end

  #
  # Set the user under which changes should be made
  #
  def as=(as)
    @connection = nil
    @as = as
  end

  protected
    #
    # The user under whose context we will be accessing the remote server
    #
    def as
      return @as
    end

    def connection(refresh = false)
      raise "All RestApi model classes must have the 'as' attribute set in order to make remote requests" unless as
      @connection = self.class.connection({:as => as}) if refresh || @connection.nil?
    end
end

class User < RestApi
  singleton

  has_many :ssh_key

  schema do
    string :login
  end
end

class Key < RestApi
  self.primary_key = 'name'
  self.element_name = 'key'

  belongs_to :user

  schema do
    string :name, 'type', :key
  end

  def type
    @attributes[:type]
  end

  validates :name, :length => {:maximum => 50},
                   :presence => true,
                   :allow_blank => false
  validates_format_of 'type',
                      :with => /^ssh-(rsa|dss)$/,
                      :message => "is not ssh-rsa or ssh-dss"
  validates :key, :length => {:maximum => 2048},
                    :presence => true,
                    :allow_blank => false

  #
  # TEMPORARY: bug fix needed in REST API
  #
  #def encode(options={})
  #  send("to_form", options)
  #end

  def to_param
    name
  end
end


if __FILE__==$0
  require 'test/unit/ui/console/testrunner'

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
    attr :login
    def initialize(login)
      @login = login
    end
    def authorization_cookie
      TestCookie.new :rh_sso, {:value => '1234'}
    end
  end

  if ENV['LIBRA_HOST']

    User.site = "https://#{ENV['LIBRA_HOST']}/broker/rest"
    User.prefix='/broker/rest/'
    user = TestUser.new 'test1@test1.com'
    begin
      info = User.find :one, :as => user
      puts info.inspect
    rescue ActiveResource::ConnectionError => e
      puts "#{e.response}=#{e.response.body}\n#{e.response.inspect}"
      #raise 
    end
    puts "-------------------\n"
  end

  if true

  require 'active_resource/http_mock'
  require 'test/unit'
  require 'mocha'

  class RestApiTest < Test::Unit::TestCase

    def setup
      @user = TestUser.new 'test1'
      auth_headers = {'Cookie' => @user.authorization_cookie.to_s, 'Authorization' => 'Basic dGVzdDE6'};

      RestApi.site = 'https://localhost'
      Key.prefix = '/user/'
      ActiveSupport::XmlMini.backend = 'REXML'
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/user/keys.xml', {'Accept' => 'application/xml'}.merge!(auth_headers), [{:type => :rsa, :name => 'test1', :value => '1234' }].to_xml(:root => 'key')
        mock.post '/user/keys.xml', {'Content-Type' => 'application/xml'}.merge!(auth_headers), {:type => :rsa, :name => 'test2', :value => '1234_2' }.to_xml(:root => 'key')
        mock.delete '/user/keys/test1.xml', {'Accept' => 'application/xml'}.merge!(auth_headers), {}

        mock.get '/user.xml', {'Accept' => 'application/xml'}.merge!(auth_headers), { :login => 'test1' }.to_xml(:root => 'user')
      end
    end

    def test_key_get_all
      items = Key.find :all, :as => @user
      assert_equal 1, items.length
    end

    def test_key_first
      assert_equal Key.first(:as => @user), Key.find(:all, :as => @user)[0]
    end

    def test_key_create
      key = Key.new :type => 'ssh-rsa', :name => 'test2', :key => '1234_2', :as => @user
      assert key.save
    end

    def test_key_validation
      key = Key.new :type => 'ssh-rsa', :name => 'test2', :as => @user
      assert !key.save
      assert_equal 1, key.errors[:key].length

      key.key = ''
      assert !key.save
      assert_equal 1, key.errors[:key].length

      key.key = 'a'
      assert key.save
      assert key.errors.empty?
    end

    def test_key_delete
      items = Key.find :all, :as => @user
      assert items[0].destroy
    end

    def test_agnostic_connection
      assert_raise RestApi::MissingUserContextError do
        RestApi.connection.is_a? ActiveResource::Connection
      end
      assert RestApi.connection({:as => {}}).is_a? RestApi::UserAwareConnection
    end

    def test_create_cookie
      connection = RestApi::UserAwareConnection.new 'http://localhost', :xml, TestUser.new('test1')
      headers = connection.authorization_header(:post, '/something')
      assert_equal 'rh_sso=1234', headers['Cookie']
    end

    def test_user_get
      user = User.find :one, :as => @user
      assert user
      assert_equal 'test1', user.login
    end
  end
  end

  Test::Unit::UI::Console::TestRunner.run(RestApiTest)
end
