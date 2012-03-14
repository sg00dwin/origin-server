 class CloudUser < StickShift::UserModel
  attr_accessor :login, :uuid, :system_ssh_keys, :env_vars, :ssh_keys, :namespace, :max_gears, :consumed_gears, :applications, :auth_method
  primary_key :login
  exclude_attributes :applications, :auth_method
  require_update_attributes :system_ssh_keys, :env_vars, :ssh_keys
  private :login=, :uuid=, :namespace=
  DEFAULT_SSH_KEY_NAME = "default"
  
  validates_each :login do |record, attribute, val|
    record.errors.add(attribute, {:message => "Invalid characters found in login '#{val}' ", :exit_code => 107}) if val =~ /["\$\^<>\|%\/;:,\\\*=~]/
  end
  
  validates_each :namespace do |record, attribute, val|
    if !(val =~ /\A[A-Za-z0-9]+\z/)
      record.errors.add attribute, {:message => "Invalid namespace: #{val}", :exit_code => 106}
    end
  end
  
  validates_each :ssh_keys do |record, attribute, val|
    val.each do |key_name, key_info|
      if !(key_name =~ /\A[A-Za-z0-9]+\z/)
        record.errors.add attribute, {:message => "Invalid key name: #{key_name}", :exit_code => 117}
      end
      if !(key_info['type'] =~ /^(ssh-rsa|ssh-dss)$/)
        record.errors.add attribute, {:message => "Invalid key type: #{key_info['type']}", :exit_code => 116}
      end
      if !(key_info['key'] =~ /\A[A-Za-z0-9\+\/=]+\z/)
        record.errors.add attribute, {:message => "Invalid ssh key: #{key_info['key']}", :exit_code => 108}
      end
    end if val
  end

  def initialize(login=nil, ssh=nil, namespace=nil, ssh_type=nil, key_name=nil)
    super()
    if not ssh.nil?
      ssh_type = "ssh-rsa" if ssh_type.to_s.strip.length == 0
      self.ssh_keys = {} unless self.ssh_keys
      key_name = CloudUser::DEFAULT_SSH_KEY_NAME if key_name.to_s.strip.length == 0
      self.ssh_keys[key_name] = { "key" => ssh, "type" => ssh_type }
    else
      self.ssh_keys = {} unless self.ssh_keys
    end
    self.login = login
    self.namespace = namespace
    self.max_gears = Rails.configuration.ss[:default_max_gears]
    self.consumed_gears = 0
  end
  
  def save
    resultIO = ResultIO.new
    unless persisted?
      #new user record
      resultIO.append(create())
    end
    
    super(@login)
    resultIO
  end

  def applications
    @applications
  end
  
  def self.find_by_uuid(obj_type_of_uuid, uuid)
    hash = StickShift::DataStore.instance.find_by_uuid(obj_type_of_uuid, uuid)
    return nil unless hash
    hash_to_obj(hash)
  end
  
  def self.hash_to_obj(hash)
    apps = []
    if hash["apps"]
      apps = []
      hash["apps"].each do |app_hash|
        app = Application.hash_to_obj(app_hash)
        apps.push(app)
      end
      hash.delete("apps")
    end
    user = super(hash)
    apps.each do |app|
      app.user = user
      app.reset_state
    end
    user.applications = apps
    user
  end
  
  def delete
    dns_service = StickShift::DnsService.instance
    reply = ResultIO.new
    begin
      dns_service.deregister_namespace(@namespace)      
      dns_service.publish        
    ensure
      dns_service.close
    end
    reply.resultIO << "Namespace #{@namespace} deleted successfully.\n"
    super(@login)
    reply
  end

  def self.find(login)
    super(login,login)
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
    return result unless key
    applications.each do |app|
      Rails.logger.debug "DEBUG: Removing #{app_name}'s system ssh keys from app: #{app.name}"
      result.append app.remove_authorized_ssh_key(key)
    end
    
    self.system_ssh_keys.delete app_name
    self.save
    result
  end
  
  def add_ssh_key(key_name, key, key_type=nil)
    self.ssh_keys = {} unless self.ssh_keys
    result = ResultIO.new

    key_type = "ssh-rsa" if key_type.to_s.strip.length == 0
    self.ssh_keys[key_name] = { "key" => key, "type" => key_type }
    self.save

    applications.each do |app|
      Rails.logger.debug "DEBUG: Adding ssh key named #{key_name} to app: #{app.name} for user #{@name}"
      result.append app.add_authorized_ssh_key(key, key_type, key_name)
    end
    result
  end
  
  def remove_ssh_key(key_name, num_keys_check=true)
    self.ssh_keys = {} unless self.ssh_keys    
    result = ResultIO.new

    # validations
    #FIXME: remove this check when client tools are updated
    raise StickShift::UserKeyException.new("ERROR: Can't remove '#{key_name}' ssh key for user #{self.login}", 
                                           124) if num_keys_check and (key_name == CloudUser::DEFAULT_SSH_KEY_NAME)
    key_info = self.ssh_keys[key_name]
    raise StickShift::UserKeyException.new("ERROR: Key name '#{key_name}' doesn't exist for user #{self.login}", 118) unless key_info
    raise StickShift::UserKeyException.new("ERROR: Can't remove all ssh keys for user #{self.login}", 
                                           122) if num_keys_check and self.ssh_keys.size <= 1

    applications.each do |app|
      Rails.logger.debug "DEBUG: Removing ssh key named #{key_name} from app: #{app.name} for user #{@name}"
      result.append app.remove_authorized_ssh_key(key_info["key"], key_name)
    end
    
    self.ssh_keys.delete key_name
    self.save
    result
  end

  def update_ssh_key(key, key_type=nil, key_name=nil)
    key_name = CloudUser::DEFAULT_SSH_KEY_NAME if key_name.to_s.strip.length == 0
    remove_ssh_key(key_name, false)
    add_ssh_key(key_name, key, key_type)
  end
 
  def get_ssh_key
    raise StickShift::UserKeyException.new("ERROR: At least one ssh key doesn't exist for user #{self.login}", 
                                           123) unless self.ssh_keys and self.ssh_keys.kind_of?(Hash)
    (self.ssh_keys.key?(CloudUser::DEFAULT_SSH_KEY_NAME)) ? self.ssh_keys[CloudUser::DEFAULT_SSH_KEY_NAME] : self.ssh_keys.keys[0]
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
  
  def update_namespace(new_ns)
    old_ns = self.namespace
    reply = ResultIO.new
    return reply if old_ns == new_ns
    self.namespace = new_ns
    
    notify_observers(:before_namespace_update)
    dns_service = StickShift::DnsService.instance
    
    begin
      raise StickShift::UserException.new("A namespace with name '#{new_ns}' already exists", 103) unless dns_service.namespace_available?(new_ns)
      
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
        raise StickShift::NodeException.new("Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact support.",143)
      end
    rescue StickShift::SSException => e
      raise
    rescue Exception => e
      Rails.logger.debug "DEBUG: Exception caught updating namespace: #{e.message}"
      Rails.logger.debug e.backtrace
      raise StickShift::SSException.new("An error occurred updating the namespace.  If the problem persists please contact support.",1)
    ensure
      dns_service.close
    end
    
    applications.each do |app|
      app.embedded.each_key do |framework|
        if app.embedded[framework].has_key?('info')
          info = app.embedded[framework]['info']
          info.gsub!(/-#{old_ns}.#{Rails.configuration.ss[:domain_suffix]}/, "-#{new_ns}.#{Rails.configuration.ss[:domain_suffix]}")
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
    dns_service = StickShift::DnsService.instance
    begin
      user = CloudUser.find(@login)
      if user
        #TODO Rework when we allow multiple domains per user
        raise StickShift::UserException.new("User with login '#{@login}' already has a domain with namespace '#{user.namespace}'", 102, resultIO)
      end

      raise StickShift::UserException.new("A namespace with name '#{namespace}' already exists", 103, resultIO) unless dns_service.namespace_available?(@namespace)

      begin
        Rails.logger.debug "DEBUG: Attempting to add namespace '#{@namespace}' for user '#{@login}'"      
        resultIO.debugIO << "Creating user entry login:#{@login} ssh:#{@ssh} namespace:#{@namespace}"
        dns_service.register_namespace(@namespace)
        @uuid = StickShift::Model.gen_uuid
        dns_service.publish
        notify_observers(:cloud_user_create_success)   
      rescue Exception => e
        Rails.logger.debug e
        begin
          #Rails.logger.debug "DEBUG: Attempting to remove namespace '#{@namespace}' after failure to add user '#{@login}'"        
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
