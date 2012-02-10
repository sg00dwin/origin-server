require 'active_support/core_ext/hash/conversions'
require 'active_resource'
require 'active_resource/associations'
require 'active_resource/reflection'

module ActiveResource
  module Formats
    #
    # The OpenShift REST API wraps the root resource element which needs
    # to be unwrapped.
    #
    module OpenshiftJsonFormat
      extend ActiveResource::Formats::JsonFormat
      extend self
      
      def decode(json)
        decoded = super
        #puts "decoded #{decoded.inspect}"
        if decoded.is_a?(Hash) and decoded.has_key?('data')
          decoded = decoded['data']
        end
        if decoded.is_a?(Array)
          decoded.each { |i| i.delete 'links' }
        else
          decoded.delete 'links'
        end
        decoded
      end
    end
  end
end


#
# Base class for connecting to the OpenShift REST API using ActiveModel conventions
#
class RestApi < ActiveResource::Base

  # ActiveResource association support
  extend ActiveResource::Associations
  include ActiveResource::Reflection

  # Raised when the authorization context is missing
  class MissingAuthorizationError < StandardError ; end

  # Don't include the root in JSON when creating/updating records
  def encode(options={})
    tmp = ActiveResource::Base.include_root_in_json
    ActiveResource::Base.include_root_in_json = false
    resp = send("to_#{self.class.format.extension}", options)
    ActiveResource::Base.include_root_in_json = tmp
    resp
  end

  #
  # An Authorization object should expose:
  #
  #  login - method returning an identifier for the user
  #
  # and one of:
  #
  #  ticket - the unique ticket for the session
  #  password - a user password
  #
  class Authorization
    attr_reader :login, :ticket, :password
    def initialize(login,ticket=nil,password=nil)
      @login = login
      @ticket = ticket
      @password = password
    end
  end


  #
  # A connection class that contains an authorization object to connect as
  #
  class UserAwareConnection < ActiveResource::Connection

    # The authorization context
    attr :as

    def initialize(url, format, as)
      super url, format
      @as = as
      @user = @as.login if @as.respond_to? :login
      @password = @as.password if @as.respond_to? :password
    end

    def authorization_header(http_method, uri)
      headers = super
      if @as.respond_to? :ticket and @as.ticket
        (headers['Cookie'] ||= '') << "rh_sso=#{@as.ticket}"
      end
      headers
    end

    #def request(*arguments)
      #puts "request\n#{arguments.inspect}"
      #resp = super
      #puts "response\n#{resp.inspect}"
      #resp
    #end

    #
    # Changes made in commit https://github.com/rails/rails/commit/51f1f550dab47c6ec3dcdba7b153258e2a0feb69#activeresource/lib/active_resource/base.rb
    # make GET consistent with other verbs (return response)
    #
    def get(path, headers = {})
      with_auth { request(:get, path, build_request_headers(headers, :get, self.site.merge(path))) } #changed, remove .body at end, removed format decode
    end
  end


  #
  # Connection properties
  #
  self.format = :openshift_json
  self.ssl_options = { :verify_mode => OpenSSL::SSL::VERIFY_NONE }
  self.timeout = 60
  self.site = if defined?(Rails) && Rails.configuration.express_api_url
    Rails.configuration.express_api_url + '/broker/rest'
  else
    'http://localhost/broker/rest'
  end

  # 
  # Track persistence state, merged from 
  # https://github.com/railsjedi/rails/commit/9333e0de7d1b8f63b19c99d21f5f65fef0ce38c3
  #
  def initialize(attributes = {}, persisted=false)
    @persisted = persisted
    @as = attributes[:as]
    attributes.delete :as
    super attributes
  end

  # changes to instantiate_record tracked below

  def new?
    !persisted?
  end

  def persisted?
    @persisted
  end

  def load_attributes_from_response(response)
    if response['Content-Length'] != "0" && response.body.strip.size > 0
      load(self.class.format.decode(response.body))
      @persisted = true
      remove_instance_variable(:@old_id) if @old_id
    end
  end

  class << self
    def custom_id(name, mutable=false)
      @primary_key = name
      if mutable
        define_method "#{name}=" do |val|
          @old_id = @attributes[name]
          @attributes[name] = val
        end
        define_method :id do
          @old_id || super
        end
      end
    end
  end

  #
  # ActiveResource association support
  #
  class << self
    def find_or_create_resource_for_collection(name)
      return reflections[name.to_sym].klass if reflections.key?(name.to_sym)
      find_or_create_resource_for(ActiveSupport::Inflector.singularize(name.to_s))
    end
    private
      def find_or_create_resource_for(name)
        return reflections[name.to_sym].klass if reflections.key?(name.to_sym)
        super
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
  #class << self
  #  def has_many(sym)
  #  end
  #  def belongs_to(sym)
  #    prefix = "#{site.path}#{sym.to_s}"
  #  end
  #end


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
  # Must provide OpenShift compatible error decoding
  #
  def load_remote_errors(remote_errors, save_cache=false)
    case self.class.format
    when ActiveResource::Formats[:openshift_json]
      ActiveSupport::JSON.decode(remote_errors.response.body)['messages'].each do |m|
        errors.add( (m['attribute'] || 'base').to_sym, m['text'].to_s) if m['text']
      end
    else
      super
    end
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
        raise MissingAuthorizationError
      end
      #elsif defined?(@connection) || superclass == Object
      #  #'Accessing RestApi without a user object'
      #  @connection = update_connection(ActiveResource::Connection.new(site, format)) if @connection.nil? || refresh
      #  @connection
      #else
      #  superclass.connection
      #end
    end

    # possibly needed to decode gets
    #def get(custom_method_name, options = {})
    #  puts 'default get'
    #  self.class.format.decode(connection(options).get(custom_method_collection_url(custom_method_name, options), headers).body) #changed
    #end

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
        rescue ActiveResource::ResourceNotFound => e
          # changed to return empty array on not found
          # Swallowing ResourceNotFound exceptions and return nil - as per
          # ActiveRecord.
          [] #changed
        end
      end

      def instantiate_collection(collection, as, prefix_options = {}) #changed
        collection.collect! { |record| instantiate_record(record, as, prefix_options) } #changed
      end

      def instantiate_record(record, as, prefix_options = {}) #changed
        new(record, true).tap do |resource| #changed for persisted flag
          resource.prefix_options = prefix_options
          resource.as = as #added
        end
      end
  end

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


#
# The REST API model object representing the currently authenticated user.
#
class User < RestApi
  singleton

  has_many :keys

  schema do
    string :login
  end

  has_many :domains
end


#
# The REST API model object representing the domain, which may contain multiple applications.
#
class Domain < RestApi
  schema do
    string :namespace
    string :ssh
  end

  custom_id :namespace, true

  has_many :applications
  def applications
    Application.find :all, { :params => { :domain_name => namespace }, :as => as }
  end

  belongs_to :user
  def user
    User.find :one, :as => as
  end

  def destroy_recursive
    connection.delete(element_path({:force => true}.merge(prefix_options)), self.class.headers)
  end
end


#
# The REST API model object representing an application instance.
#
class Application < RestApi
  schema do
    string :name, :creation_time
    string :uuid, :domain_id
    string :cartridge, :server_identity
  end

  custom_id :name

  has_many :aliases
  belongs_to :domain
  self.prefix = "#{RestApi.site.path}/domains/:domain_name/"
  def domain_id
    self.prefix_options[:domain_name] || super
  end
  def domain_id=(id)
    self.prefix_options[:domain_name] = id
    super
  end
  def domain
    Domain.find domain_id, :as => as
  end
  def domain=(domain)
    domain_id = domain.is_a? String ? domain : domain.namespace
  end
  def base_url
    namespace = domain_id
    base_domain = Rails.configuration.base_domain
    "#{@attributes[:name]}-#{namespace}.#{base_domain}"
  end
  def web_url
    url = 'http://' 
    url << base_url
  end
  def git_url
    "ssh://#{@attributes[:uuid]}@#{base_url}/~/git/#{@attributes[:name]}.git/"
  end
end


#
# The REST API model object representing a domain name alias to an application.
#
class Alias < RestApi
  schema do
    string :name
  end

  belongs_to :application
end


#
# The REST API model object representing an SSH public key.
#
class Key < RestApi
  self.element_name = 'key'

  schema do
    string :name, 'type', :ssh
  end
  def id() name end

  belongs_to :user
  self.prefix = "#{RestApi.site.path}/user/"
  def type
    @attributes[:type]
  end

  validates :name, :length => {:maximum => 50},
                   :presence => true,
                   :allow_blank => false
  validates_format_of 'type',
                      :with => /^ssh-(rsa|dss)$/,
                      :message => "is not ssh-rsa or ssh-dss"
  validates :ssh, :length => {:maximum => 2048},
                    :presence => true,
                    :allow_blank => false
end

run_tests = true

if __FILE__==$0 && run_tests

  require 'test/unit/ui/console/testrunner'

  require 'test/unit'
  require 'mocha'
  require 'base64'
  require 'time'

  @@integrated = !!ENV['REST_API_TEST_REMOTE']

  unless @@integrated
    #TODO fix mock tests and remove this warning!
    puts ""
    puts "WARNING: mock tests don't work quite yet..."
    puts "Try running again with the following environment variable(s) set:"
    puts ""
    puts "  REST_API_TEST_REMOTE=1"
    puts "  LIBRA_HOST=ec2-foo.compute-1.amazonaws.com (use an actual devenv hostname)"
    puts ""
    exit 1
  end

  class RestApiTest < Test::Unit::TestCase

    def setup
      if @@integrated
        setup_integrated
      else
        setup_mock
      end
    end

    def setup_integrated
      host = ENV['LIBRA_HOST'] || 'localhost'
      RestApi.site = "https://#{host}/broker/rest"
      RestApi.prefix='/broker/rest/'

      @ts = Time.now.to_i

      @user = RestApi::Authorization.new "test1+#{@ts}@test1.com", @ts

      auth_headers = {'Authorization' => "Basic #{Base64.encode64("#{@user.login}:#{@user.password}").strip}"}

      domain = Domain.new :namespace => "xyz#{@ts}", :as => @user
      domain.ssh = "foo"
      assert domain.save
    end

    # TODO fix
    def setup_mock
      require 'active_resource/http_mock'

      @user = RestApi::Authorization.new 'test1', '1234'
      auth_headers = {'Cookie' => "rh_sso=1234", 'Authorization' => 'Basic dGVzdDE6'};

      RestApi.site = 'https://localhost'
      Key.prefix = '/user/'
      User.prefix = '/'
      Domain.prefix = '/'
      Application.prefix = "#{Domain.prefix}domains/:domain_name/"
      ActiveSupport::XmlMini.backend = 'REXML'
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/user/keys.json', {'Accept' => 'application/json'}.merge!(auth_headers), [{:type => :rsa, :name => 'test1', :value => '1234' }].to_json()
        mock.post '/user/keys.json', {'Content-Type' => 'application/json'}.merge!(auth_headers), {:type => :rsa, :name => 'test2', :value => '1234_2' }.to_json()
        mock.delete '/user/keys/test1.json', {'Accept' => 'application/json'}.merge!(auth_headers), {}
        mock.get '/user.json', {'Accept' => 'application/json'}.merge!(auth_headers), { :login => 'test1' }.to_json()
        mock.get '/domains.json', {'Accept' => 'application/json'}.merge!(auth_headers), [{ :namespace => 'adomain' }].to_json()
        mock.get '/domains/adomain/applications.json', {'Accept' => 'application/json'}.merge!(auth_headers), [{ :name => 'app1' }, { :name => 'app2' }].to_json()
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
      items = Key.find :all, :as => @user

      orig_num_keys = items.length

      key = Key.new :type => 'ssh-rsa', :name => "test#{@ts}", :ssh => @ts, :as => @user
      assert key.save

      items = Key.find :all, :as => @user
      assert_equal orig_num_keys + 1, items.length
    end

    def test_key_validation
      key = Key.new :type => 'ssh-rsa', :name => 'test2', :as => @user
      assert !key.save
      assert_equal 1, key.errors[:ssh].length

      key.ssh = ''
      assert !key.save
      assert_equal 1, key.errors[:ssh].length

      key.ssh = 'a'
      assert key.save
      assert key.errors.empty?
    end

    def test_key_delete
      items = Key.find :all, :as => @user

      orig_num_keys = items.length

      key = Key.new :type => 'ssh-rsa', :name => "test#{@ts}", :ssh => @ts, :as => @user
      assert key.save

      items = Key.find :all, :as => @user
      assert_equal orig_num_keys + 1, items.length

      assert items[1].destroy

      items = Key.find :all, :as => @user
      assert_equal orig_num_keys, items.length
    end

    def test_agnostic_connection
      assert_raise RestApi::MissingAuthorizationError do
        RestApi.connection.is_a? ActiveResource::Connection
      end
      assert RestApi.connection({:as => {}}).is_a? RestApi::UserAwareConnection
    end

    def test_create_cookie
      connection = RestApi::UserAwareConnection.new 'http://localhost', :xml, RestApi::Authorization.new('test1', '1234')
      headers = connection.authorization_header(:post, '/something')
      assert_equal 'rh_sso=1234', headers['Cookie']
    end

    def test_user_get
      user = User.find :one, :as => @user
      assert user
      assert_equal @user.login, user.login
    end

    def test_domains_get
      domains = Domain.find :all, :as => @user
      assert_equal 1, domains.length
      assert_equal "xyz#{@ts}", domains[0].namespace
    end

    def test_domains_first
      domain = Domain.first(:as => @user)
      assert_equal "xyz#{@ts}", domain.namespace
    end

    def test_domains_update
      domains = Domain.find :all, :as => @user
      assert_equal 1, domains.length
      assert_equal "xyz#{@ts}", domains[0].namespace

      d = domains[0]
      d.namespace = "abc#{@ts}"

      assert d.save

      domains = Domain.find :all, :as => @user
      assert_equal 1, domains.length
      assert_equal "abc#{@ts}", domains[0].namespace
    end

    def test_domains_applications
      domain = Domain.first(:as => @user)

      app1 = Application.new :name => 'app1', :cartridge => 'php-5.3', :as => @user
      app2 = Application.new :name => 'app2', :cartridge => 'php-5.3', :as => @user

      app1.domain = domain
      app2.domain = domain

      assert app1.save
      assert app2.save

      apps = domain.applications
      assert_equal 2, apps.length
      assert_equal 'app1', apps[0].name
      assert_equal 'app2', apps[1].name
    end

  Test::Unit::UI::Console::TestRunner.run(RestApiTest)

  end

end
