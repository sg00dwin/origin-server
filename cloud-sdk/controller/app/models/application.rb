require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class Application < Cloud::Sdk::Model
  attr_accessor :user, :framework, :creation_time, :uuid, :embedded, :aliases, :name, :server_identity, :health_check_path, :node_profile
  primary_key :name  
  exclude_attributes :user, :health_check_path, :dependencies, :node_profile

  validate :extended_validator
  
  def extended_validator
    notify_observers(:validate_application)
  end

  def framework_cartridge
    framework.split('-')[0..-2].join('-')
  end

  def initialize(user=nil,app_name=nil,uuid=nil,node_profile=nil,framework=nil)
    self.user = user
    self.name = app_name
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.embedded = {}
    self.node_profile = node_profile
    self.framework = framework
  end
  
  def self.find(user, app_name)
    app = super(user.rhlogin, app_name)
    app.user = user
    app.reset_state
    app
  end
  
  def self.find_all(user)
    apps = super(user.rhlogin)
    apps.map do |app|
      app.user = user
      app.reset_state
      app
    end
  end
  
  #saves the application object in the datastore
  def save
    super(user.rhlogin)
  end
  
  #deletes the application object from the datastore
  def delete
    super(user.rhlogin)
  end
  
  #creates a new application container on a node and initializes it
  def create
    notify_observers(:before_application_create)
    self.server_identity = ApplicationContainerProxy.find(self.node_profile)
    ApplicationContainerProxy.create(self)
  end
  
  #destroys all application containers
  def destroy
    ApplicationContainerProxy.destroy(self)
  end
  
  #configures cartridges for the application
  def configure_dependencies
    resultIO = ApplicationContainerProxy.preconfigure_cartridge(self.framework, self)
    resultIO.append ApplicationContainerProxy.configure_cartridge(self.framework, self)
  end
  
  def deconfigure_dependencies
    #<framework>::deconfigure
  end
  
  def add_user_ssh_keys
    user.system_ssh_keys.each_value do |ssh_key|
      add_authorized_ssh_key(ssh_key)
    end if app.user.system_ssh_keys
  end
  
  def add_user_env_vars
    user.env_vars.each do |key, value|
      add_env_var(key, value)
    end if user.env_vars
  end

  def add_authorized_ssh_key(ssh_key)
    ApplicationContainerProxy.add_authorized_ssh_key(self, ssh_key)
  end
  
  def remove_authorized_ssh_key(ssh_key)
    ApplicationContainerProxy.remove_authorized_ssh_key(self, ssh_key)
  end
  
  def add_env_var(key, value)
    ApplicationContainerProxy.add_env_var(self, key, value)
  end
  
  def remove_env_var(key)
    ApplicationContainerProxy.remove_env_var(self, key)
  end
  
  def add_broker_key
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")                                                                                                                                                                 
    cipher.encrypt
    cipher.key = OpenSSL::Digest::SHA512.new(Rails.application.config.cdk[:broker_auth_secret]).digest
    cipher.iv = iv = cipher.random_iv
    token = {:app_name => name,
             :rhlogin => user.rhlogin,
             :creation_time => app.creation_time}
    encrypted_token = cipher.update(JSON.generate(token))
    encrypted_token << cipher.final
  
    public_key = OpenSSL::PKey::RSA.new(File.read('config/keys/public.pem'), Rails.application.config.cdk[:broker_auth_rsa_secret])
    encrypted_iv = public_key.public_encrypt(iv)
    ApplicationContainerProxy.add_broker_auth_key(self, Base64::encode64(encrypted_iv).gsub("\n", ''), Base64::encode64(encrypted_token).gsub("\n", ''))
  end
  
  def remove_broker_key
    ApplicationContainerProxy.remove_broker_auth_key(self)
  end
  
  def update_namespace(new_ns, old_ns)
    begin
      node = NodeProxy.new(@server_identity)
      result = node.execute_direct(app.framework, 'update_namespace', "#{app.name} #{self.namespace} #{self.namespace_was} #{app.uuid}")[0]
      if (result && defined?(result.results) && result.results.has_key?(:data))
        exitcode = result.results[:data][:exitcode]
        output = result.results[:data][:output]
        server.log_result_output(output, exitcode, self, name, app.attributes)
        return exitcode == 0
      end
    rescue Exception => e
      Rails.logger.debug "Exception caught updating namespace #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace #{e.message}"
      Rails.logger.debug e.backtrace
    end
    return false
  end

#  def tidy
#    <framework>::tidy
#  end
#  
#  def move
#    <framework>::move
#  end
#  
#  def info
#    <framework>::info
#  end
#  
#  def post_install
#    <framework>::post-install
#  end
#  
#  def post_remove
#    <framework>::post-remove
#  end
#  
#  def pre_install
#    <framework>::pre-install
#  end
#  
#  def reload
#    <framework>::reload
#  end
#  
#  def start
#    <framework>::start
#  end
#  
#  def stop
#    <framework>::stop
#  end
#  
#  def status
#    <framework>::status
#  end
#  
#  def force_stop
#    <framework>::force-stop
#  end
#  
#  def add_alias
#    <framework>::add-alias
#  end
#  
#  def remove_alias
#    <framework>::remove-alias
#  end
end