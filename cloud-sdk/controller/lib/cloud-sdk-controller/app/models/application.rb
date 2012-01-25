class Application < Cloud::Sdk::Cartridge
  attr_accessor :state, :group_instance_map, :comp_instance_map, :conn_endpoints_list
  attr_accessor :domain, :creation_time, :uuid, :aliases, :uid
  primary_key :uuid
    
  #state_machine :state, :initial => :not_created do
  #  event(:create) { transition :not_created => :creating }
  #  event(:create_complete) { transition :creating => :stopped }
  #  event(:create_error) { transition :creating => :destroying }
  #  event(:start) { transition :stopped => :starting }
  #  event(:start_error) { transition :starting => :stopped }
  #  event(:start_complete) { transition :starting => :running }
  #  event(:stop) { transition :running => :stopping }
  #  event(:stop_error) { transition :stopping => :running }
  #  event(:stop_complete) { transition :stopping => :stopped }
  #  event(:destroy) { transition :stopped => :destroying }
  #  event(:destroy_complete) { transition :destroying => :not_created }
  #end

  validate :extended_validator

  def extended_validator
    notify_observers(:validate_application)
  end

  def framework_cartridge
    framework.split('-')[0..-2].join('-')
  end

  def initialize(domain=nil, name=nil, uuid=nil)
    self.user = user
    self.name = name
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
  end
  
  def self.find(user, app_name)
    app = nil
    if user.applications
      user.applications.each do |next_app|
        if next_app.name == app_name
          app = next_app
          break
        end
      end
    else
      app = super(user.login, app_name)
      return nil unless app
      app.user = user
      app.reset_state
    end
    app
  end
  
  def self.find_by_uuid(app_uuid)
    app = nil
    user = CloudUser.find_by_uuid(self.name, app_uuid)
    user.applications.each do |next_app|
      if next_app.uuid == app_uuid
        app = next_app
        break
      end
    end
    app
  end
  
  def self.find_all(user)
    apps = nil
    if user.applications
      apps = user.applications
    else
      apps = super(user.login)
      apps.each do |app|
        app.user = user
        app.reset_state
      end
      user.applications = apps
    end
    apps
  end
  
  def self.get_available_cartridges(cart_type)
    Cloud::Sdk::ApplicationContainerProxy.find_available.get_available_cartridges(cart_type)
  end
  
  #saves the application object in the datastore
  def save
    super(user.login)
  end
  
  #deletes the application object from the datastore
  def delete
    super(user.login)
  end
  
  def from_json(*args)
    super(*args)
    self.container ||= Cloud::Sdk::ApplicationContainerProxy.instance(self.server_identity)
    self
  end
  
  #creates a new application container on a node and initializes it
  def create(container=nil)
    reply = ResultIO.new
    self.class.notify_observers(:before_application_create, {:application => self, :reply => reply})
    if container
      self.container = container
    else
      self.container = Cloud::Sdk::ApplicationContainerProxy.find_available(self.node_profile)
    end
    self.server_identity = self.container.id
    self.uid = self.container.reserve_uid
    save
    reply.append self.container.create(self)
    self.class.notify_observers(:after_application_create, {:application => self, :reply => reply})        
    reply
  end
  
  #convinence method to cleanup an application
  def cleanup_and_delete
    reply = ResultIO.new
    reply.append self.deconfigure_dependencies
    reply.append self.destroy
    reply.append self.destroy_dns
    self.delete
    reply
  end
  
  #destroys all application containers
  def destroy
    reply = ResultIO.new
    self.class.notify_observers(:before_application_destroy, {:application => self, :reply => reply})    
    reply.append self.container.destroy(self) if self.container
    self.class.notify_observers(:after_application_destroy, {:application => self, :reply => reply})    
    reply
  end
  
  #configures cartridges for the application
  def configure_dependencies
    reply = ResultIO.new
    self.class.notify_observers(:before_application_configure, {:application => self, :reply => reply})
    reply.append self.container.preconfigure_cartridge(self, self.framework)
    reply.append self.container.configure_cartridge(self, self.framework)
    reply.append process_cartridge_commands(reply.cart_commands)
    self.class.notify_observers(:after_application_configure, {:application => self, :reply => reply})
    reply
  end
  
  def deconfigure_dependencies
    reply = ResultIO.new
    self.class.notify_observers(:before_application_deconfigure, {:application => self, :reply => reply})  
    reply.append self.container.deconfigure_cartridge(self, self.framework)
    reply.append process_cartridge_commands(reply.cart_commands)
    self.class.notify_observers(:after_application_deconfigure, {:application => self, :reply => reply})
    reply
  end
  
  def add_system_ssh_keys
    reply = ResultIO.new
    @user.system_ssh_keys.each_value do |ssh_key|
      reply.append add_authorized_ssh_key(ssh_key)
    end if @user.system_ssh_keys
    reply
  end
  
  def add_ssh_keys
    reply = ResultIO.new
    @user.ssh_keys.each do |key_name, ssh_key|
      reply.append add_authorized_ssh_key(ssh_key["key"], ssh_key["type"], key_name)
    end if @user.ssh_keys
    reply
  end
  
  def add_system_env_vars
    reply = ResultIO.new    
    @user.env_vars.each do |key, value|
      reply.append add_env_var(key, value)
    end if @user.env_vars
    reply
  end

  def add_authorized_ssh_key(ssh_key, key_type=nil, comment=nil)
    self.container.add_authorized_ssh_key(self, ssh_key, key_type, comment)
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
    reply = ResultIO.new
    self.class.notify_observers(:before_create_dns, {:application => self, :reply => reply})    
    dns = Cloud::Sdk::DnsService.instance
    begin
      public_hostname = @container.get_public_hostname
      dns.register_application(@name,@user.namespace, public_hostname)
      dns.publish
    ensure
      dns.close
    end
    self.class.notify_observers(:after_create_dns, {:application => self, :reply => reply})    
    reply
  end
  
  def destroy_dns
    reply = ResultIO.new
    self.class.notify_observers(:before_destroy_dns, {:application => self, :reply => reply})
    dns = Cloud::Sdk::DnsService.instance
    begin
      dns.deregister_application(@name,@user.namespace)
      dns.publish
    ensure
      dns.close
    end
    self.class.notify_observers(:after_destroy_dns, {:application => self, :reply => reply})  
    reply
  end
  
  def recreate_dns
    reply = ResultIO.new
    self.class.notify_observers(:before_recreate_dns, {:application => self, :reply => reply})    
    dns = Cloud::Sdk::DnsService.instance
    begin
      dns.deregister_application(@name,@user.namespace)
      public_hostname = @container.get_public_hostname
      dns.register_application(@name,@user.namespace, public_hostname)
      dns.publish
    ensure
      dns.close
    end
    self.class.notify_observers(:after_recreate_dns, {:application => self, :reply => reply})    
    reply
  end
  
  def add_broker_key
    iv, token = Cloud::Sdk::AuthService.instance.generate_broker_key(self)
    self.container.add_broker_auth_key(self, Base64::encode64(iv).gsub("\n", ''), Base64::encode64(token).gsub("\n", ''))
  end
  
  def remove_broker_key
    self.container.remove_broker_auth_key(self)
  end
  
  def update_namespace(new_ns, old_ns)
    
    updated = false
    begin
      result = self.container.update_namespace(self, @framework, new_ns, old_ns)
      process_cartridge_commands(result.cart_commands)
      updated = result.exitcode == 0
    rescue Exception => e
      Rails.logger.debug "Exception caught updating namespace #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace #{e.message}"
      Rails.logger.debug e.backtrace
    end
    return updated 
  end

  def elaborate_descriptor
    self.default_profile.groups.each { |k, g|
      gpath = self.name + "." + g.name
      gi = GroupInstance.new(self.name, self.default_profile.name, gpath )
      self.group_instance_map[gpath] = gi
      gi.elaborate(g, group_list)
    }
    # make connection_endpoints out of provided connections
    self.default_profile.connections.each { |name, conn|
      inst1 = ComponentInstance::find_component_in_cart(profile, app, conn.components[0], self.name)
      inst2 = ComponentInstance::find_component_in_cart(profile, app, conn.components[1], self.name)
      ComponentInstance::establish_connections(inst1, inst2, app)
    }
    # check self.comp_instance_map for component instances
    # check self.group_instance_map for group instances
    # check self.conn_endpoints_list for list of connection endpoints (fully resolved)

    # resolve group co-locations
    colocate_groups
  end

  def colocate_groups
    self.conn_endpoints_list.each { |conn|
      if conn.pub.type.match(/^FILESYSTEM/) or conn.pub.type.match(/^AFUNIX/)
        ginst1 = self.group_instance_map[conn.from_comp_inst.group_instance_name]
        ginst2 = self.group_instance_map[conn.to_comp_inst.group_instance_name]
        # these two group instances need to be colocated
      end
    }
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
  
  def threaddump
    self.container.threaddump(self, @framework)
  end

  def expose_port
    self.container.expose_port(self, @framework)
  end
  
  def conceal_port
    self.container.conceal_port(self, @framework)
  end

  def add_alias(server_alias)
    self.aliases = [] unless self.aliases
    raise Cloud::Sdk::UserException.new("Alias '#{server_alias}' already exists for '#{@name}'", 255) if self.aliases.include? server_alias
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
        raise Cloud::Sdk::UserException.new("Alias '#{server_alias}' does not exist for '#{@name}'", 255, reply)
      end      
    end
    reply
  end
  
  def add_dependency(dep)
    reply = ResultIO.new
    self.class.notify_observers(:before_add_dependency, {:application => self, :dependency => dep, :reply => reply})
    # Create persistent storage app entry on configure (one of the first things)
    Rails.logger.debug "DEBUG: Adding embedded app info from persistant storage: #{@name}:#{dep}"
    self.embedded = {} unless self.embedded
    
    raise Cloud::Sdk::UserException.new("#{dep} already embedded in '#{@name}'", 101) if self.embedded[dep]
    c_reply,component_details = self.container.add_component(self, dep)
    reply.append c_reply
    self.embedded[dep] = { "info" => component_details }
    self.save
    self.class.notify_observers(:after_add_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end
  
  def remove_dependency(dep)
    reply = ResultIO.new
    self.class.notify_observers(:before_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    self.embedded = {} unless self.embedded
        
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]
    reply.append self.container.remove_component(self, dep)
    self.embedded.delete dep
    self.save
    self.class.notify_observers(:after_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end
  
  def start_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]    
    self.container.start_component(self, dep)
  end
  
  def stop_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]    
    self.container.stop_component(self, dep)
  end
  
  def restart_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]    
    self.container.restart_component(self, dep)
  end
  
  def reload_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]    
    self.container.reload_component(self, dep)
  end
  
  def dependency_status(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded[dep]  
    self.container.component_status(self, dep)
  end
  
  private
  
  def self.hash_to_obj(hash)
    app = super(hash)
    app.container ||= Cloud::Sdk::ApplicationContainerProxy.instance(app.server_identity)
    app
  end
  
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
