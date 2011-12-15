class CloudUser < Cloud::Sdk::Model
  attr_accessor :rhlogin, :uuid, :ssh, :namespace, :system_ssh_keys, :env_vars, :email_address, :ssh_keys
  primary_key :rhlogin
  private :rhlogin=, :uuid=
  
  validates_each :rhlogin do |record, attribute, val|
    record.errors.add(attribute, {:message => "Invalid characters found in RHlogin '#{val}' ", :code => 107}) if val =~ /["\$\^<>\|%\/;:,\\\*=~]/
  end
  
  validates_each :namespace do |record, attribute, val|
    if !(val =~ /\A[A-Za-z0-9]+\z/)
      record.errors.add attribute, {:message => "Invalid namespace: #{val}", :exit_code => 106}
    end
  end
  
  validates_each :ssh do |record, attribute, val|
    if !(val =~ /\A[A-Za-z0-9\+\/=]+\z/)
      record.errors.add attribute, {:message => "Invalid ssh key: #{val}", :exit_code => 108}
    end
  end
  
  def initialize(rhlogin=nil, ssh=nil, namespace=nil)
    super()
    self.rhlogin, self.ssh, self.namespace = rhlogin, ssh, namespace
  end
  
  def save
    resultIO = ResultIO.new
    unless persisted?
      #new user record
      resultIO.append(create())
    else
      if ssh_changed?
        applications.each do |app|
          resultIO.append app.remove_authorized_ssh_key(self.ssh_was)
          resultIO.append app.add_authorized_ssh_key(self.ssh)
        end
      end
      update_namespace() if namespace_changed?
    end
    
    super(@rhlogin)
    resultIO
  end

  def applications
    Application.find_all(self)
  end
  
  def delete
    dns_service = Cloud::Sdk::DnsService.instance
    reply = ResultIO.new
    begin
      dns_service.deregister_namespace(@namespace)      
      dns_service.publish        
    ensure
      dns_service.close
    end
    reply.resultIO << "Namespace #{@namespace} deleted successfully.\n"
    super(@rhlogin)
    reply
  end

  def self.find(rhlogin)
    super(rhlogin,rhlogin)
  end
  
  def add_system_ssh_key(app_name, key)
    self.system_ssh_keys = {} unless self.system_ssh_keys
    result = ResultIO.new
    self.system_ssh_keys[app_name] = key
    self.save
    applications.each do |app|
      Rails.logger.debug "DEBUG: Adding #{app_name}'s system ssh keys to app: #{app.name}"
      result.append app.add_authorized_ssh_key(key)
    end
    result
  end
  
  def remove_system_ssh_key(app_name)
    self.system_ssh_keys = {} unless self.system_ssh_keys    
    result = ResultIO.new
    key = self.system_ssh_keys[app_name]
    return unless key
    applications.each do |app|
      Rails.logger.debug "DEBUG: Removing #{app_name}'s system ssh keys from app: #{app.name}"
      result.append app.remove_authorized_ssh_key(key)
    end
    
    self.system_ssh_keys.delete app_name
    self.save
    result
  end
  
  def add_secondary_ssh_key(key_name, key)
    self.ssh_keys = {} unless self.ssh_keys
    result = ResultIO.new
    self.ssh_keys[key_name] = key
    self.save
    applications.each do |app|
      Rails.logger.debug "DEBUG: Adding secondary key named #{key_name} to app: #{app.name} for user #{@name}"
      result.append app.add_authorized_ssh_key(key)
    end
    result
  end
  
  def remove_secondary_ssh_key(key_name)
    self.ssh_keys = {} unless self.ssh_keys    
    result = ResultIO.new
    key = self.ssh_keys[app_name]
    return unless key
    applications.each do |app|
      Rails.logger.debug "DEBUG: Removing secondary key named #{key_name} from app: #{app.name} for user #{@name}"
      result.append app.remove_authorized_ssh_key(key)
    end
    
    self.ssh_keys.delete key_name
    self.save
    result
  end
  
  def add_env_var(key, value)
    result = ResultIO.new
    self.env_vars = {} unless self.env_vars
    self.env_vars[key] = value
    self.save
    applications.each do |app|
      Rails.logger.debug "DEBUG: Adding env var #{key} to app: #{app.name}"
      result.append app.add_env_var(key,value)
    end
    result
  end
  
  def remove_env_var(key)
    result = ResultIO.new
    self.env_vars = {} unless self.env_vars
    self.env_vars.delete key
    self.save
    applications.each do |app|
      Rails.logger.debug "DEBUG: Removing env var #{key} to app: #{app.name}"
      result.append app.remove_env_var(key)
    end
    result
  end
  
  private
  
  def create
    resultIO = ResultIO.new
    notify_observers(:before_cloud_user_create)
    dns_service = Cloud::Sdk::DnsService.instance
    begin
      if CloudUser.find(@rhlogin)
        raise Cloud::Sdk::UserException.new("A user with RHLogin '#{@rhlogin}' already exists", 102, resultIO)
      end

      raise Cloud::Sdk::UserException.new("A namespace with name '#{namespace}' already exists", 103, resultIO) unless dns_service.namespace_available?(@namespace)

      begin
        Rails.logger.debug "DEBUG: Attempting to add namespace '#{@namespace}' for user '#{@rhlogin}'"      
        resultIO.debugIO << "Creating user entry login:#{@rhlogin} ssh:#{@ssh} namespace:#{@namespace}"
        dns_service.register_namespace(@namespace)
        @uuid = Cloud::Sdk::Model.gen_uuid
        dns_service.publish
        notify_observers(:cloud_user_create_success)      
      rescue Exception => e
        Rails.logger.debug e
        begin
          Rails.logger.debug "DEBUG: Attempting to remove namespace '#{@namespace}' after failure to add user '#{@rhlogin}'"        
          dns_service.deregister_namespace(@namespace)
          dns_service.publish
          notify_observers(:cloud_user_create_error)      
        ensure
          raise
        end
      end
    ensure
      dns_service.close
      notify_observers(:after_cloud_user_create)
    end
    resultIO
  end
  
  def update_namespace
    notify_observers(:before_namespace_update)
    
    dns_service = Cloud::Sdk::DnsService.instance
    raise Cloud::Sdk::UserException.new("A namespace with name '#{namespace}' already exists", 103) unless dns_service.namespace_available?(@namespace)
    
    begin
      dns_service.register_namespace(self.namespace)
      dns_service.deregister_namespace(self.namespace_was)      

      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespaces for app: #{app.name}"
        dns_service.deregister_application(app.name, self.namespace_was, @rhlogin)
        dns_service.register_application(app.name, self.namespace, @rhlogin)
      end
      
      update_namespace_failures = []
      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespace for app: #{app_name}"
        result = app.update_namespace(self.namespace, self.namespace_was)
        update_namespace_failures.push(app.name) unless result
      end
      
      if update_namespace_failures.empty?
        dns_service.publish        
        notify_observers(:namespace_update_success)
      else
        notify_observers(:namespace_update_error)
        raise Cloud::Sdk::NodeException.new("Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact support.",143), caller[0..5]
      end
    rescue Cloud::Sdk::CdkException => e
      raise
    rescue Exception => e
      response.debug "Exception caught updating namespace: #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace: #{e.message}"
      Rails.logger.debug e.backtrace
      raise Cloud::Sdk::CdkException.new("An error occurred updating the namespace.  If the problem persists please contact support.",1), caller[0..5]
    ensure
      dns_service.close
      
      applications.each do |app|
        app.embedded.each_key do |framework|
          if app.embedded["framework"].has_key?('info')
            info = app.embedded[framework]['info']
            info.gsub!(/-#{old_namespace}.#{Rails.application.config.cdk[:domain_suffix]}/, "-#{new_namespace}.#{Rails.application.config.cdk[:domain_suffix]}")
            app.embedded[framework]['info'] = info
          end
        end
        app.save        
      end
    end
    notify_observers(:after_namespace_update)
  end
end
