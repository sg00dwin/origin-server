require 'rubygems'
require 'json'
require 'cloud-sdk-common'
require 'app/lib/node_proxy'
require 'app/lib/dns_service'
require 'app/lib/auth_service'

class Application < Cloud::Sdk::Model
  attr_accessor :user, :framework, :creation_time, :uuid, :embedded, :aliases, :name, :server_identity, :health_check_path, :node_profile, :container
  primary_key :name  
  exclude_attributes :user, :health_check_path, :dependencies, :node_profile, :container

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
    return nil unless app
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
  
  def self.get_available_cartridges(cart_type)
    ApplicationContainerProxy.find_available.get_available_cartridges(cart_type)
  end
  
  #saves the application object in the datastore
  def save
    super(user.rhlogin)
  end
  
  #deletes the application object from the datastore
  def delete
    super(user.rhlogin)
  end
  
  def from_json(*args)
    super(*args)
    self.container ||= ApplicationContainerProxy.new(self.server_identity)
    self
  end
  
  #creates a new application container on a node and initializes it
  def create
    notify_observers(:before_application_create)
    self.container = ApplicationContainerProxy.find_available(self.node_profile)
    self.server_identity = self.container.id
    resultIO = self.container.create(self)
    notify_observers(:after_application_create)    
    resultIO
  end
  
  #destroys all application containers
  def destroy
    notify_observers(:before_application_destroy)    
    resultIO = self.container.destroy(self)
    notify_observers(:after_application_create)    
    resultIO
  end
  
  #configures cartridges for the application
  def configure_dependencies
    notify_observers(:before_application_configure)
    resultIO = self.container.preconfigure_cartridge(self, self.framework)
    resultIO.append self.container.configure_cartridge(self, self.framework)
    resultIO.append process_cartridge_commands(resultIO.cart_commands)
    notify_observers(:after_application_configure)    
    resultIO
  end
  
  def deconfigure_dependencies
    notify_observers(:before_application_deconfigure)    
    resultIO = self.container.deconfigure_cartridge(self, self.framework)
    resultIO.append process_cartridge_commands(resultIO.cart_commands)    
    notify_observers(:after_application_deconfigure)    
    resultIO
  end
  
  def add_user_ssh_keys
    reply = ResultIO.new
    @user.system_ssh_keys.each_value do |ssh_key|
      reply.append add_authorized_ssh_key(ssh_key)
    end if @user.system_ssh_keys
    reply
  end
  
  def add_user_env_vars
    reply = ResultIO.new    
    @user.env_vars.each do |key, value|
      reply.append add_env_var(key, value)
    end if @user.env_vars
    reply
  end

  def add_authorized_ssh_key(ssh_key)
    self.container.add_authorized_ssh_key(self, ssh_key)
  end
  
  def remove_authorized_ssh_key(ssh_key)
    self.container.remove_authorized_ssh_key(self, ssh_key)
  end
  
  def add_env_var(key, value)
    self.container.add_env_var(self, key, value)
  end
  
  def remove_env_var(key)
    self.container.remove_env_var(self, key)
  end
  
  def create_dns
    notify_observers(:before_create_dns)
    dns = DnsService.new
    begin
      public_hostname = @container.get_public_hostname
      dns.register_application(@name,@user.namespace, public_hostname)
      dns.publish
    ensure
      dns.close
    end
    notify_observers(:after_create_dns)
  end
  
  def destroy_dns
    notify_observers(:before_destroy_dns)
    dns = DnsService.new
    begin
      dns.deregister_application(@name,@user.namespace)
      dns.publish      
    ensure
      dns.close
    end
    notify_observers(:after_destroy_dns)    
  end
  
  def add_broker_key
    iv, token = AuthService.generate_broker_key(self)
    self.container.add_broker_auth_key(self, Base64::encode64(iv).gsub("\n", ''), Base64::encode64(token).gsub("\n", ''))
  end
  
  def remove_broker_key
    self.container.remove_broker_auth_key(self)
  end
  
  def update_namespace(new_ns, old_ns)
    begin
      result = self.container.execute_direct(app.framework, 'update_namespace', "#{app.name} #{self.namespace} #{self.namespace_was} #{app.uuid}")[0]
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
      raise
    end
    return false
  end
  
  def start
    self.container.start(self, @framework)
  end
  
  def stop
    self.container.stop(self, @framework)
  end
  
  def restart
    self.container.restart(self, @framework)
  end
  
  def force_stop
    self.container.force_stop(self, @framework)
  end
  
  def reload
    self.container.reload(self, @framework)
  end
  
  def status
    self.container.status(self, @framework)
  end
  
  def tidy
    self.container.tidy(self, @framework)
  end
  
  def add_alias(server_alias)
    self.aliases = [] unless self.aliases
    raise WorkflowException.new("Alias '#{server_alias}' already exists for '#{@name}'", 255), caller[0..5] if self.aliases.include? server_alias
    reply = ResultIO.new
    begin
      self.aliases.push(server_alias)
      reply.append self.container.add_alias(self, @framework, server_alias)
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.inspect
      reply.append self.container.remove_alias(self, @framework, server_alias)      
      self.aliases.delete(server_alias)
    ensure
      self.save      
    end
    reply
  end
  
  def remove_alias(server_alias)
    self.aliases = [] unless self.aliases
    reply = ResultIO.new
    begin
      reply.append self.container.remove_alias(self, @framework, server_alias)
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.inspect
      raise
    ensure
      if self.aliases.include? server_alias
        self.aliases.delete(server_alias)
        self.save
      else
        raise WorkflowException.new("Alias '#{server_alias}' does not exist for '#{@name}'", 255, reply), caller[0..5]
      end      
    end
    reply
  end
  
  def add_dependency(dep)
    self.class.notify_observers(:before_add_dependency, self, dep)
    # Create persistent storage app entry on configure (one of the first things)
    Rails.logger.debug "DEBUG: Adding embedded app info from persistant storage: #{@name}:#{dep}"
    self.embedded = {} unless self.embedded
    
    raise WorkflowException.new("#{dep} already embedded in '#{@name}'", 101), caller[0..5] if self.embedded[dep]
    reply,component_details = self.container.add_component(self, dep)
    self.embedded[dep] = { "info" => component_details }
    self.save
    self.class.notify_observers(:after_add_dependency, self, dep)
    reply
  end
  
  def remove_dependency(dep)
    self.class.notify_observers(:before_remove_dependency, self, dep)
    self.embedded = {} unless self.embedded
        
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]
    reply = self.container.remove_component(self, dep)
    self.embedded.delete dep
    self.save
    self.class.notify_observers(:after_remove_dependency, self, dep)    
    reply
  end
  
  def start_dependency(dep)
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]    
    self.container.start_component(self, dep)
  end
  
  def stop_dependency(dep)
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]    
    self.container.stop_component(self, dep)
  end
  
  def restart_dependency(dep)
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]    
    self.container.restart_component(self, dep)
  end
  
  def reload_dependency(dep)
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]    
    self.container.reload_component(self, dep)
  end
  
  def dependency_status(dep)
    raise WorkflowException.new("#{dep} not embedded in '#{@name}', try adding it first", 101), caller[0..5] unless self.embedded[dep]  
    self.container.component_status(self, dep)
  end
  
  private
  
  def process_cartridge_commands(commands)
    result = ResultIO.new
    commands.each do |command_item|
      case command_item[:command]
      when "SYSTEM_SSH_KEY_ADD"
        key = command_item[:args][0]
        result.append self.user.add_system_ssh_key(self.name, key)
      when "SYSTEM_SSH_KEY_REMOVE"
        result.append self.user.remove_system_ssh_key(self.name)
      when "ENV_VAR_ADD"
        key = command_item[:args][0]
        value = command_item[:args][1]
        result.append self.user.add_env_var(key,value)
      when "ENV_VAR_REMOVE"
        key = command_item[:args][0]
        result.append self.user.remove_env_var(key)        
      when "BROKER_KEY_ADD"
        add_broker_key
      when "BROKER_KEY_REMOVE"
        remove_broker_key
      end
    end
    result
  end
end