 class CloudUser < StickShift::UserModel
  attr_accessor :login, :uuid, :system_ssh_keys, :env_vars, :ssh_keys, :namespace, :max_gears, :consumed_gears, :applications, :auth_method, :save_jobs 
  primary_key :login
  exclude_attributes :applications, :auth_method, :save_jobs
  require_update_attributes :system_ssh_keys, :env_vars, :ssh_keys
  private :login=, :uuid=, :namespace=, :save_jobs=
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
    
    if applications && save_jobs
      gears = []
      applications.each do |app|
        gears += app.gears
      end

      tag = ""
      if save_jobs['removes']
        save_jobs['removes'].each do |action, values|
          handle = RemoteJob.create_parallel_job
                 
          RemoteJob.run_parallel_on_gears(gears, handle) { |exec_handle, gear|
            save_jobs['removes'].each do |action, values|
              case action
              when 'ssh_keys'
                values.each do |value|
                  ssh_key = value[0]
                  ssh_key_comment = value[1]
                  job = gear.ssh_key_job_remove(ssh_key, ssh_key_comment)
                  RemoteJob.add_parallel_job(exec_handle, tag, gear, job)
                end
              when 'env_vars'
                values.each do |value|
                  env_var_key = value[0]
                  job = gear.env_var_job_remove(env_var_key)
                  RemoteJob.add_parallel_job(exec_handle, tag, gear, job)
                end
              end
            end
          }
          RemoteJob.get_parallel_run_results(handle) { |tag, gear, output, status|
            if status != 0
              raise StickShift::NodeException.new("Error removing settings from gear: #{gear} with status: #{status} and output: #{output}", 143)
            end
          }
          save_jobs['removes'].clear
        end
      end
    end

    super(@login)
    
    if applications && save_jobs
      if save_jobs['adds']
        handle = RemoteJob.create_parallel_job
       
        RemoteJob.run_parallel_on_gears(gears, handle) { |exec_handle, gear|
          save_jobs['adds'].each do |action, values|
            case action
            when 'ssh_keys'
              values.each do |value|
                ssh_key = value[0]
                ssh_key_type = value[1]
                ssh_key_comment = value[2]
                job = gear.ssh_key_job_add(ssh_key, ssh_key_type, ssh_key_comment)
                RemoteJob.add_parallel_job(exec_handle, tag, gear, job)
              end
            when 'env_vars'
              values.each do |value|
                env_var_key = value[0]
                env_var_value = value[1]
                job = gear.env_var_job_add(env_var_key, env_var_value)
                RemoteJob.add_parallel_job(exec_handle, tag, gear, job)
              end
            end
          end
        }
        RemoteJob.get_parallel_run_results(handle) { |tag, gear, output, status|
          if status != 0
            raise StickShift::NodeException.new("Error adding settings to gear: #{gear} with status: #{status} and output: #{output}", 143)
          end
        }
        save_jobs['adds'].clear
      end
    end

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
    self.system_ssh_keys[app_name] = key 
    add_save_job('adds', 'ssh_keys', [key, nil, app_name])
  end
  
  def remove_system_ssh_key(app_name)
    self.system_ssh_keys = {} unless self.system_ssh_keys    
    key = self.system_ssh_keys[app_name]
    return unless key
    self.system_ssh_keys.delete app_name
    add_save_job('removes', 'ssh_keys', [key, app_name])
  end
  
  def add_ssh_key(key_name, key, key_type=nil)
    self.ssh_keys = {} unless self.ssh_keys
    key_type = "ssh-rsa" if key_type.to_s.strip.length == 0
    self.ssh_keys[key_name] = { "key" => key, "type" => key_type }
    add_save_job('adds', 'ssh_keys', [key, key_type, key_name])
  end

  def remove_ssh_key(key_name)
    self.ssh_keys = {} unless self.ssh_keys

    # validations
    raise StickShift::UserKeyException.new("ERROR: Key name '#{key_name}' doesn't exist for user #{self.login}", 118) if not self.ssh_keys.has_key?(key_name)
    
    add_save_job('removes', 'ssh_keys', [self.ssh_keys[key_name]["key"], key_name])
    self.ssh_keys.delete key_name
  end
  
  def update_ssh_key(key, key_type=nil, key_name=nil)
    key_name = CloudUser::DEFAULT_SSH_KEY_NAME if key_name.to_s.strip.length == 0
    remove_ssh_key(key_name)
    add_ssh_key(key_name, key, key_type)
  end

  def get_ssh_key
    raise StickShift::UserKeyException.new("ERROR: No ssh keys found for user #{self.login}", 
                                           123) if self.ssh_keys.nil? or not self.ssh_keys.kind_of?(Hash)
    (self.ssh_keys.key?(CloudUser::DEFAULT_SSH_KEY_NAME)) ? self.ssh_keys[CloudUser::DEFAULT_SSH_KEY_NAME] : self.ssh_keys.keys[0]
  end
 
  def add_env_var(key, value)
    self.env_vars = {} unless self.env_vars
    self.env_vars[key] = value
    add_save_job('adds', 'env_vars', [key, value])
  end
  
  def remove_env_var(key)
    self.env_vars = {} unless self.env_vars
    self.env_vars.delete key
    add_save_job('removes', 'env_vars', [key])
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
  
  def add_save_job(section, object, value)
    self.save_jobs = {} unless self.save_jobs
    self.save_jobs[section] = {} unless self.save_jobs[section]
    self.save_jobs[section][object] = [] unless self.save_jobs[section][object]
    self.save_jobs[section][object] << value
  end
  
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
