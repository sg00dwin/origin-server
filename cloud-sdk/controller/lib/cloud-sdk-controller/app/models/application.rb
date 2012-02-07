require 'state_machine'

class Application < Cloud::Sdk::Cartridge
  attr_accessor :user, :creation_time, :uuid, :aliases, 
                :state, :group_instance_map, :comp_instance_map, :conn_endpoints_list,
                :domain, :group_override_map, :working_comp_inst_hash,
                :working_group_inst_hash
  primary_key :name
  exclude_attributes :user, :comp_instance_map, :group_instance_map
  include_attributes :comp_instances, :group_instances
  
  validate :extended_validator

  def extended_validator
    notify_observers(:validate_application)
  end

  def initialize(user=nil, app_name=nil, uuid=nil, node_profile=nil, framework=nil)
    self.user = user
    from_descriptor({"Name"=>app_name, "Subscribes"=>{"doc-root"=>{"Type"=>"FILESYSTEM:doc-root"}}})
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.requires_feature = [framework]
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
  
  def self.get_available_cartridges(cart_type=nil)
    cart_names = CartridgeCache.cartridge_names(cart_type)
  end
  
  #saves the application object in the datastore
  def save
    super(user.login)
  end
  
  #deletes the application object from the datastore
  def delete
    super(user.login)
  end
  
  #creates a new application container on a node and initializes it
  def create(container=nil)
    result_io = ResultIO.new
    self.class.notify_observers(:before_application_create, {:application => self, :reply => result_io})    
    containers_created = []
    if @group_instance_map == nil || @comp_instance_map == nil || @group_instance_map.empty? || @comp_instance_map.empty?
      self.elaborate_descriptor
    end
    
    begin    
      Rails.logger.debug "Creating application containers"
      group_instances.uniq.each do |ginst|
        app_container = ApplicationContainer.new(self, ginst.node_profile)
        
        #backward compat: first containers UUID = app.uuid
        app_container.uuid = self.uuid if containers_created.size == 0
        
        containers_created.push app_container
        create_result = app_container.create
        result_io.append create_result

        unless create_result.exitcode == 0
          raise NodeException.new("Unable to create container on node", "-100", result_io)
        end
        ginst.application_containers = [app_container]
      end
      self.class.notify_observers(:application_creation_success, {:application => self, :reply => result_io})              
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")
      Rails.logger.debug "Rolling back application container creation"
      containers_created.each do |app_container|
        app_container.destroy
      end
      group_instances.each {|ginst| ginst.application_containers = []}
      self.class.notify_observers(:application_creation_failure, {:application => self, :reply => result_io})
      raise
    ensure
      save
    end
    self.class.notify_observers(:after_application_create, {:application => self, :reply => result_io})
    result_io
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
    reply.append self.application_container.get_proxy.destroy(self, self.application_container)
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
  
  def add_broker_key
    iv, token = Cloud::Sdk::AuthService.instance.generate_broker_key(self)
    self.container.add_broker_auth_key(self, Base64::encode64(iv).gsub("\n", ''), Base64::encode64(token).gsub("\n", ''))
  end
  
  def remove_broker_key
    self.container.remove_broker_auth_key(self)
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
  
  def create_dns
    reply = ResultIO.new
    self.class.notify_observers(:before_create_dns, {:application => self, :reply => reply})    
    dns = Cloud::Sdk::DnsService.instance
    begin
      public_hostname = self.container.get_public_hostname
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
      public_hostname = self.container.get_public_hostname
      dns.register_application(@name,@user.namespace, public_hostname)
      dns.publish
    ensure
      dns.close
    end
    self.class.notify_observers(:after_recreate_dns, {:application => self, :reply => reply})    
    reply
  end
  
  def update_namespace(new_ns, old_ns)
    updated = false
    begin
      result = self.container.update_namespace(self, self.framework, new_ns, old_ns)
      process_cartridge_commands(result.cart_commands)
      updated = result.exitcode == 0
    rescue Exception => e
      Rails.logger.debug "Exception caught updating namespace #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace #{e.message}"
      Rails.logger.debug e.backtrace
    end
    return updated 
  end
  
  def start
    self.container.start(self, self.framework)
  end
  
  def stop
    self.container.stop(self, self.framework)
  end
  
  def restart
    self.container.restart(self, self.framework)
  end
  
  def force_stop
    self.container.force_stop(self, self.framework)
  end
  
  def reload
    self.container.reload(self, self.framework)
  end
  
  def status
    self.container.status(self, self.framework)
  end
  
  def tidy
    self.container.tidy(self, self.framework)
  end
  
  def threaddump
    self.container.threaddump(self, self.framework)
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
      reply.append self.container.add_alias(self, self.framework, server_alias)
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.inspect
      reply.append self.container.remove_alias(self, self.framework, server_alias)      
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
      reply.append self.container.remove_alias(self, self.framework, server_alias)
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
    self.cart_data = {} if @cart_data.nil?
    
    raise Cloud::Sdk::UserException.new("#{dep} already embedded in '#{@name}'", 101) if self.embedded.include? dep
    c_reply,component_details = self.container.add_component(self, dep)
    reply.append c_reply
    self.cart_data[dep] = { "info" => component_details }
    self.save
    self.class.notify_observers(:after_add_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end
  
  def remove_dependency(dep)
    reply = ResultIO.new
    self.class.notify_observers(:before_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    self.embedded = {} unless self.embedded
        
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    reply.append self.container.remove_component(self, dep)
    self.embedded.delete dep
    self.save
    self.class.notify_observers(:after_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end
  
  def start_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.container.start_component(self, dep)
  end
  
  def stop_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.container.stop_component(self, dep)
  end
  
  def restart_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.container.restart_component(self, dep)
  end
  
  def reload_dependency(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.container.reload_component(self, dep)
  end
  
  def dependency_status(dep)
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.container.component_status(self, dep)
  end

  def elaborate_descriptor
    self.group_instance_map = {} if group_instance_map.nil?
    self.comp_instance_map = {} if comp_instance_map.nil?
    self.working_comp_inst_hash = {}
    self.working_group_inst_hash = {}
    self.group_override_map = {} 
    self.conn_endpoints_list = [] 
    default_profile = @profile_name_map[@default_profile]
    
    default_profile.group_overrides.each do |n, v|
      from = self.name + "." + n
      to = self.name + "." + v
      self.group_override_map[from] = to
    end

    default_profile.groups.each { |g|
      gpath = self.name + "." + g.name
      mapped_path = group_override_map[gpath] || ""
      gi = group_instance_map[mapped_path]
      if gi.nil?
        gi = GroupInstance.new(self.name, self.default_profile, g.name, gpath)
      else
        gi.merge(self.name, self.default_profile, g.name, gpath)
      end
      self.group_instance_map[gpath] = gi
      self.working_group_inst_hash[gpath] = gi
      gi.elaborate(g, "", self)
    }
    # delete entries in {group,comp}_instance_map that do 
    # not exist in working_{group,comp}_inst_hash
    self.group_instance_map.delete_if { |k,v| self.working_group_inst_hash[k].nil? }
    self.comp_instance_map.delete_if { |k,v| self.working_comp_inst_hash[k].nil? }
    
    # make connection_endpoints out of provided connections
    default_profile.connections.each { |conn|
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
      if conn.from_connector.type.match(/^FILESYSTEM/) or conn.from_connector.type.match(/^AFUNIX/)
        ginst1 = self.group_instance_map[conn.from_comp_inst.group_instance_name]
        ginst2 = self.group_instance_map[conn.to_comp_inst.group_instance_name]
        next if ginst1==ginst2
        # these two group instances need to be colocated
        ginst1.merge(ginst2.cart_name, ginst2.profile_name, ginst2.group_name, ginst2.name, ginst2.component_instances)
        self.group_instance_map[conn.to_comp_inst.group_instance_name] = ginst1
      end
    }
  end

  def generate_group_overrides(default_profile)
    if not default_profile.group_overrides.empty?
      default_profile.group_overrides.each do |n, v|
        from = self.name + "." + n
        to = self.name + "." + v
        self.group_override_map[from] = to
      end
    else
      default_profile = @profile_name_map[@default_profile]
      first_group = default_profile.groups[0]
      default_profile.groups.each do |g|
        next if first_group==g
        default_profile.group_override_map[self.name + "." + g.name] = self.name + "." + first_group.name
      end
    end
  end

  def auto_merge_top_groups(default_profile)
    first_group = default_profile.groups[0]
    gpath = self.name + "." + first_group.name
    gi = self.group_instance_map[gpath]
    first_group.component_refs.each { |comp_ref|
      cpath = self.name + "." + comp_ref.name
      ci = self.comp_instance_map[cpath]
      ci.dependencies.each { |cdep|
        cdepinst = self.comp_instance_map[cdep]
        ginst = self.group_instance_map[cdepinst.group_instance_name]
        next if ginst==gi
        Rails.logger.debug "Auto-merging group #{ginst.name} into #{gi.name}"
        # merge ginst into gi
        gi.merge(ginst.cart_name, ginst.profile_name, ginst.group_name, ginst.name, ginst.component_instances)
        self.group_instance_map[cdepinst.group_instance_name] = gi
      }
    }
  end
  
  #backward compat
  def framework_cartridge  
    fcart = self.framework
    return fcart.split('-')[0..-2].join('-') unless fcart.nil?
    return nil
  end
  
  #backward compat: get framework cartridge from all application dependencies
  def framework
    framework_carts = CartridgeCache.cartridge_names('standalone')
    self.requires_feature.each do |feature|
      if framework_carts.include? feature
        return feature
      end
    end
    return nil
  end

  #backward compat  
  def application_container
    if self.group_instances.nil?
      self.elaborate_descriptor
    end
    
    group_instance = self.group_instances.first
    return nil unless group_instance
    
    return group_instance.application_containers.first
  end
  
  #backward compat: get ApplicationContainerProxy
  def container
    return nil if self.application_container.nil?
    return self.application_container.get_proxy
  end
  
  def embedded
    return self.requires_feature - CartridgeCache.cartridge_names('standalone')
  end
  
  def run_on_all_containers(&block)
    self.group_instances.uniq.each do |ginst|
      ginst.application_containers do |container|
        yield container
      end
    end
  end

  def comp_instances
    @comp_instance_map = {} if @comp_instance_map.nil?
    @comp_instance_map.values
  end
  
  def comp_instances=(data)
    comp_instance_map_will_change!    
    @comp_instance_map = {} if @comp_instance_map.nil?
    data.each do |value|
      if value.class == ComponentInstance
        @comp_instance_map[value.name] = value
      else
        key = value["name"]            
        @comp_instance_map[key] = ComponentInstance.new
        @comp_instance_map[key].attributes=value
      end
    end
  end

  def group_instances
    @group_instance_map = {} if @group_instance_map.nil?
    @group_instance_map.values
  end
  
  def group_instances=(data)
    group_instance_map_will_change!    
    @group_instance_map = {} if @group_instance_map.nil?
    data.each do |value|
      if value.class == GroupInstance
        @group_instance_map[value.name] = value
      else
        key = value["name"]            
        @group_instance_map[key] = GroupInstance.new
        @group_instance_map[key].attributes=value
      end
    end
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
