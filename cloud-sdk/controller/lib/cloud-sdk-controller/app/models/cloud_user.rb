class CloudUser < Cloud::Sdk::UserModel
  attr_accessor :rhlogin, :uuid, :system_ssh_keys, :env_vars, :ssh_keys, :ssh, :ssh_type, :namespace, :key, :type
  primary_key :rhlogin
  private :rhlogin=, :uuid=, :ssh=, :namespace=
  exclude_attributes :key, :type
  
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
  
  validates_each :ssh_type, :allow_nil => true do |record, attribute, val|
    if !(val =~ /^(ssh-rsa|ssh-dss)$/)
      record.errors.add attribute, {:message => "Invalid ssh key type: #{val}", :exit_code => 116}
    end
  end
  
  def initialize(rhlogin=nil, ssh=nil, namespace=nil, ssh_type='ssh-rsa')
    super()
    ssh_type = "ssh-rsa" if ssh_type.to_s.strip.length == 0
    self.rhlogin, self.ssh, self.namespace, self.ssh_type = rhlogin, ssh, namespace, ssh_type
  end
  
  def save
    resultIO = ResultIO.new
    unless persisted?
      #new user record
      resultIO.append(create())
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
  
  def add_secondary_ssh_key(key_name, key, key_type=nil)
    self.ssh_keys = {} unless self.ssh_keys
    result = ResultIO.new
    self.ssh_keys[key_name] = { :key => key, :type => key_type }
    self.save
    applications.each do |app|
      Rails.logger.debug "DEBUG: Adding secondary key named #{key_name} to app: #{app.name} for user #{@name}"
      result.append app.add_authorized_ssh_key(key, key_type, key_name)
    end
    result
  end
  
  def remove_secondary_ssh_key(key_name)
    self.ssh_keys = {} unless self.ssh_keys    
    result = ResultIO.new
    key = self.ssh_keys[key_name]
    raise Cloud::Sdk::UserKeyException.new("ERROR: Key name '#{key_name}' doesn't exist for user #{self.rhlogin}", 118) unless key
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
  
  def update_ssh_key(new_key, key_type)
    reply = ResultIO.new    
    return reply if self.ssh == new_key
    
    self.applications.each do |app|
      reply.append app.remove_authorized_ssh_key(self.ssh)
      reply.append app.add_authorized_ssh_key(new_key, key_type)
    end
    @ssh = new_key
    @ssh_type = key_type
    reply.append self.save
    reply
  end
  
  def update_namespace(new_ns)
    old_ns = self.namespace
    reply = ResultIO.new
    return reply if old_ns == new_ns
    self.namespace = new_ns
    
    notify_observers(:before_namespace_update)
    dns_service = Cloud::Sdk::DnsService.instance
    raise Cloud::Sdk::UserException.new("A namespace with name '#{new_ns}' already exists", 103) unless dns_service.namespace_available?(new_ns)
    
    begin
      dns_service.register_namespace(new_ns)
      dns_service.deregister_namespace(old_ns)
  
      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespaces for app: #{app.name}"
        dns_service.deregister_application(app.name, old_ns)
        public_hostname = app.container.get_public_hostname
        dns_service.register_application(app.name, new_ns, public_hostname)
      end
      
      update_namespace_failures = []
      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespace for app: #{app.name}"
        result = app.update_namespace(new_ns, old_ns)
        update_namespace_failures.push(app.name) unless result
      end

      if update_namespace_failures.empty?
        dns_service.publish
        notify_observers(:namespace_update_success)
      else
        notify_observers(:namespace_update_error)
        raise Cloud::Sdk::NodeException.new("Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact support.",143)
      end
    rescue Cloud::Sdk::CdkException => e
      raise
    rescue Exception => e
      Rails.logger.debug "DEBUG: Exception caught updating namespace: #{e.message}"
      Rails.logger.debug e.backtrace
      raise Cloud::Sdk::CdkException.new("An error occurred updating the namespace.  If the problem persists please contact support.",1)
    ensure
      dns_service.close
    end
    
    applications.each do |app|
      app.embedded.each_key do |framework|
        if app.embedded[framework].has_key?('info')
          info = app.embedded[framework]['info']
          info.gsub!(/-#{old_ns}.#{Rails.application.config.cdk[:domain_suffix]}/, "-#{new_ns}.#{Rails.application.config.cdk[:domain_suffix]}")
          app.embedded[framework]['info'] = info
        end
      end
      app.save
    end
    
    reply.append self.save
    notify_observers(:after_namespace_update)
    reply
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
          #Rails.logger.debug "DEBUG: Attempting to remove namespace '#{@namespace}' after failure to add user '#{@rhlogin}'"        
          #dns_service.deregister_namespace(@namespace)
          #dns_service.publish
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

end
