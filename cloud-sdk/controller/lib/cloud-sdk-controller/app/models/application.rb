require 'state_machine'

class Application < Cloud::Sdk::Cartridge
  attr_accessor :user, :creation_time, :uuid, :aliases, :cart_data,
                :state, :group_instance_map, :comp_instance_map, :conn_endpoints_list,
                :domain, :group_override_map, :working_comp_inst_hash,
                :working_group_inst_hash, :configure_order, :start_order,
                :scalable, :proxy_cartridge, :init_git_url
  primary_key :name
  exclude_attributes :user, :comp_instance_map, :group_instance_map, 
                :working_comp_inst_hash, :working_group_inst_hash,
                :init_git_url
  include_attributes :comp_instances, :group_instances
  
  validate :extended_validator

  def extended_validator
    notify_observers(:validate_application)
  end

  # @param [CloudUser] user
  # @param [String] app_name Application name
  # @param [optional, String] uuid Unique identifier for the application
  # @param [deprecated, String] node_profile Node profile for the first application gear
  # @param [deprecated, String] framework Cartridge name to use as the framwwork of the application
  def initialize(user=nil, app_name=nil, uuid=nil, node_profile=nil, framework=nil, template=nil, will_scale=false)
    self.user = user
    
    if template.nil?
      from_descriptor({"Name"=>app_name, "Subscribes"=>{"doc-root"=>{"Type"=>"FILESYSTEM:doc-root"}}})
      self.requires_feature = []
      self.requires_feature << framework unless framework.nil?      
    else
      template_descriptor = YAML.load(template.descriptor_yaml)
      template_descriptor["Name"] = app_name
      from_descriptor(template_descriptor)
      @init_git_url = template.git_url
    end
    
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.scalable = will_scale
    
    if self.scalable and framework != "haproxy-1.4"
      self.proxy_cartridge = "haproxy-1.4"
      self.requires_feature.insert(0, self.proxy_cartridge)
      prof = @profile_name_map[@default_profile]
      conn = Cloud::Sdk::Connection.new("auto_scale")
      conn.components = ["cart-#{self.proxy_cartridge}", "cart-#{framework}"]
      prof.add_connection(conn)
    end
  end
  
  # Find an application to which user has access
  # @param [CloudUser] user
  # @param [String] app_name
  # @return [Application]
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
  
  # Find an applications to which user has access
  # @param [CloudUser] user
  # @return [Array<Application>]
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
  
  def self.find_by_uuid(uuid)
    hash = Cloud::Sdk::DataStore.instance.find_by_uuid(self.name,uuid)
    return nil unless hash
    user = CloudUser.hash_to_obj hash
    app  = nil
    user.applications.each do |next_app|
      if next_app.uuid == uuid
        app = next_app
        break
      end
    end
    return app
  end
  
  # @overload Application.get_available_cartridges(cart_type)
  #   @deprecated
  #   Returns List of names of available cartridges of specified type
  #   @param [String] cart_type Must be "standalone" or "embedded" or nil
  #   @return [Array<String>] 
  # @overload Application.get_available_cartridges
  #   @return [Array<String>]   
  #   Returns List of names of all available cartridges
  def self.get_available_cartridges(cart_type=nil)
    cart_names = CartridgeCache.cartridge_names(cart_type)
  end
  
  # Saves the application object in the datastore
  def save
    super(user.login)
  end
  
  # Deletes the application object from the datastore
  def delete
    super(user.login)
  end
  
  # Processes the application descriptor and creates all the gears necessary to host the application.
  # Destroys application on all gears if any gear fails
  # @return [ResultIO]
  def create
    result_io = ResultIO.new
    self.class.notify_observers(:before_application_create, {:application => self, :reply => result_io})
    gears_created = []
    begin
      elaborate_descriptor()
      
      Rails.logger.debug "Creating gears"
      group_instances.uniq.each do |ginst|
        gear = Gear.new(self, ginst)
        #FIXME: backward compat: first gears UUID = app.uuid
        gear.uuid = self.uuid if gears_created.size == 0
        
        gears_created.push gear
        create_result = gear.create
        ginst.reused_by.each { |gname|
          if gname.include? self.web_cart
            # register dns here
            self.add_dns(gear.uuid[0..9], @user.namespace, gear.get_proxy.get_public_hostname)
            break
          end
        }
        # self.save
        result_io.append create_result
        unless create_result.exitcode == 0
          raise Cloud::Sdk::NodeException.new("Unable to create gear on node", "-100", result_io)
        end

        ginst.gears << gear

        #TODO: save gears here
      end
      self.add_ssh_keys(gears_created)
      self.add_system_ssh_keys(gears_created)
      self.class.notify_observers(:application_creation_success, {:application => self, :reply => result_io})              
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")
      Rails.logger.debug "Rolling back application gear creation"
      result_io.append self.destroy
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
    reply.append self.destroy_dns
    reply.append self.deconfigure_dependencies
    reply.append self.destroy
    self.delete
    reply
  end
  
  # Destroys all gears. Logs message but does not throw an exception on failure to delete any particular gear.
  def destroy
    reply = ResultIO.new
    self.class.notify_observers(:before_application_destroy, {:application => self, :reply => reply})
    s,f = run_on_gears(nil, reply, false) do |gear, r|
      r.append gear.destroy
      group_instance = self.group_instance_map[gear.group_instance_name]
      group_instance.gears.delete(gear)
      self.save
    end
          
    f.each do |data|
      Rails.logger.debug("Unable to clean up application on gear #{data[:gear]} due to exception #{data[:exception].message}")
      Rails.logger.debug(data[:exception].backtrace.inspect)
    end
    self.class.notify_observers(:after_application_destroy, {:application => self, :reply => reply})    
    reply
  end

  def web_cart
    web_cart = nil
    return framework if not self.scalable
    framework_carts = CartridgeCache.cartridge_names('standalone')
    self.requires_feature.each do |feature|
      if framework_carts.include? feature and feature != self.proxy_cartridge
        web_cart = feature 
        break
      end
    end
    raise Exception.new("Cannot find web framework for the application") if web_cart.nil?
    web_cart
  end

  def scaleup
    result_io = ResultIO.new
    return result_io if not self.scalable
    wb = web_cart
    new_gear = nil
    # find the group instance where the web-cartridge is residing
    self.group_instance_map.keys.each { |ginst_name|
      next if not ginst_name.include? wb
      ginst = self.group_instance_map[ginst_name]
      result, new_gear = ginst.add_gear(self)
      result_io.append result
      self.add_dns(new_gear.uuid[0..9], @user.namespace, new_gear.get_proxy.get_public_hostname)
      break
    }
    if not new_gear.nil?
      result_io.append self.configure_dependencies
      self.add_system_env_vars([new_gear])
    end
    result_io
  end

  def scaledown
    result_io = ResultIO.new
    return result_io if not self.scalable
    wb = web_cart
    # find the group instance where the web-cartridge is residing
    self.group_instance_map.keys.each { |ginst_name|
      next if not ginst_name.include? wb
      ginst = self.group_instance_map[ginst_name]

      # remove any gear out of this ginst
      raise Exception.new("Cannot scale below one gear") if ginst.gears.length == 1

      gear = ginst.gears.first

      dns = Cloud::Sdk::DnsService.instance
      begin
        dns.deregister_application(gear.uuid[0..9], @user.namespace)
        dns.publish
      ensure
        dns.close
      end

      comps_to_deconfigure = gear.configured_components.dup
      comps_to_deconfigure.each { |conf_comp|
        cinst = self.comp_instance_map[conf_comp]
        result_io.append gear.deconfigure(cinst)
      }

      result_io.append gear.destroy
      ginst.gears.delete gear
      break
    }
    # inform anyone who needs to know that this gear is no more
    execute_connections
    self.save
    result_io
  end
  
  # Elaborates the descriptor, deconfigures cartridges that were removed and configures cartridges that were added to the application dependencies.
  # If a node is empty after removing components, then the gear is destroyed. Errors that occur while removing cartridges are logged but no exception is thrown.
  # If an error occurs while configuring a cartridge, then the cartirdge is deconfigures on all nodes and an exception is thrown.
  def configure_dependencies
    reply = ResultIO.new
    self.class.notify_observers(:before_application_configure, {:application => self, :reply => reply})
    
    removed_component_instances = elaborate_descriptor()
    #remove unused components
    removed_component_instances.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.deconfigure(comp_inst)
        r.append process_cartridge_commands(r.cart_commands)
        # self.save
      end
      
      f.each do |failed_data|
        Rails.logger.debug("Failed to deconfigure cartridge #{comp_inst.parent_cart_name} on gear #{failed_data[:gear].server_identity}:#{failed_data[:gear].uuid}")
        Rails.logger.debug("Exception #{failed_data[:exception].message}")
        Rails.logger.debug("#{failed_data[:exception].backtrace.inspect}")
      end
      
      run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.destroy if gear.configured_components.length == 0
        # self.save        
      end
      group_inst.gears.delete_if { |gear| gear.configured_components.length == 0 }
    end
    cleanup_deleted_components
    # self.save
    
    exceptions = []
    Rails.logger.debug "Configure order is #{self.configure_order.inspect}"
    #process new additions
    #TODO: fix configure after framework cartridge is no longer a requirement for adding embedded cartridges
    self.configure_order.reverse.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      begin
        group_inst.fulfil_requirements(self)
        run_on_gears(group_inst.gears, reply) do |gear, r|
          doExpose = false
          if comp_inst.parent_cart_name==web_cart
            doExpose = true if not gear.configured_components.include? comp_inst.name
          end
          r.append gear.configure(comp_inst, @init_git_url)
          r.append gear.expose_port(comp_inst) if doExpose
          r.append process_cartridge_commands(r.cart_commands)
          # self.save
        end
      rescue Exception => e
        Rails.logger.debug e.message
        Rails.logger.debug e.backtrace.inspect        
        
        succesful_gears = []
        succesful_gears = e.message[:succesful].map{|g| g[:gear]} if e.message[:succesful]
        gear_exception = e.message[:exception]        

        #remove failed component from all gears
        run_on_gears(succesful_gears, reply, false) do |gear, r|
          r.append gear.deconfigure(comp_inst)
          r.append process_cartridge_commands(r.cart_commands)
          #self.save
        end
        
        #remove failed cartridge dependency
        self.requires_feature.delete(comp_inst.parent_cart_name)
        #self.save
        
        #destroy any unused gears
        run_on_gears(nil, reply, false) do |gear, r|
          r.append gear.destroy if gear.configured_components.length == 0
          #self.save
        end

        self.save
        exceptions << gear_exception
      end
    end
    
    unless exceptions.empty?
      raise exceptions.first
    end
    
    execute_connections

    self.save
    self.class.notify_observers(:after_application_configure, {:application => self, :reply => reply})
    reply
  end

  # execute all connections
  def execute_connections
    return if not self.scalable
    self.conn_endpoints_list.each { |conn|
      # get publisher's gears, execute the connector, and
      # give the output to subscriber gears
      pub_inst = self.comp_instance_map[conn.from_comp_inst]
      pub_ginst = self.group_instance_map[pub_inst.group_instance_name]

      r = ResultIO.new
      pub_out = []
      run_on_gears(pub_ginst.gears, r, false) do |gear, r|
        appname = gear.uuid[0..9]
        appname = self.name if pub_inst.parent_cart_name == self.framework
        gout, gstatus = gear.execute_connector(pub_inst, conn.from_connector.name, [appname, self.user.namespace, gear.uuid])
        if gstatus==0
          pub_out.push("'#{gear.uuid}'='#{gout}'")
        end
      end

      input_to_subscriber = Shellwords::shellescape(pub_out.join(' '))
      Rails.logger.debug "Output of publisher - '#{pub_out}'"

      sub_inst = self.comp_instance_map[conn.to_comp_inst]
      sub_ginst = self.group_instance_map[sub_inst.group_instance_name]

      run_on_gears(sub_ginst.gears, r, false) do |gear, r|
        appname = gear.uuid[0..9]
        appname = self.name if sub_inst.parent_cart_name == self.framework
        gout, gstatus = gear.execute_connector(sub_inst, conn.to_connector.name, [appname, self.user.namespace, gear.uuid, input_to_subscriber])
      end
    }
  end
  
  # Deconfigure all cartriges for the application. Errors are logged but no exception is thrown.
  def deconfigure_dependencies
    reply = ResultIO.new
    self.class.notify_observers(:before_application_deconfigure, {:application => self, :reply => reply})  
    self.configure_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      begin
        run_on_gears(group_inst.gears, reply, false) do |gear, r|
          r.append gear.deconfigure(comp_inst)
          r.append process_cartridge_commands(r.cart_commands)
          # self.save
        end
      rescue  Exception => e
        self.save
        raise e
      end
    end
    self.save
    self.class.notify_observers(:after_application_deconfigure, {:application => self, :reply => reply})
    reply
  end
  
  # Start a particular dependency on all gears that host it. 
  # If unable to start a component, the application is stopped on all gears
  # @param [String] dependency Name of a cartridge to start. Set to nil for all dependencies.
  # @param [Boolean] force_stop_on_failure
  def start(dependency=nil, stop_on_failure=true)
    reply = ResultIO.new
    self.class.notify_observers(:before_start, {:application => self, :reply => reply, :dependency => dependency})
    self.start_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      begin
        group_inst = self.group_instance_map[comp_inst.group_instance_name]
        run_on_gears(group_inst.gears, reply) do |gear, r|
          r.append gear.start(comp_inst)
        end
      rescue Exception => e
        gear_exception = e.message[:exception]
        self.stop(dependency,false,false) if stop_on_failure
        raise gear_exception
      end
    end
    self.class.notify_observers(:after_start, {:application => self, :reply => reply, :dependency => dependency})
    reply
  end
  
  # Stop a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge to start. Set to nil for all dependencies.
  # @param [Boolean] force_stop_on_failure
  # @param [Boolean] throw_exception_on_failure
  def stop(dependency=nil,force_stop_on_failure=true, throw_exception_on_failure=true)
    reply = ResultIO.new
    self.class.notify_observers(:before_stop, {:application => self, :reply => reply, :dependency => dependency})
    self.start_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.stop(comp_inst)
      end
      
      if(f.length > 0)
        self.force_stop(dependency,false) if(force_stop_on_failure)
        raise f[0][:exception] if(throw_exception_on_failure)
      end
    end
    self.class.notify_observers(:after_stop, {:application => self, :reply => reply, :dependency => dependency})
    reply    
  end
  
  # Force stop a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge to stop. Set to nil for all dependencies.
  # @param [Boolean] throw_exception_on_failure
  def force_stop(dependency=nil, throw_exception_on_failure=true)
    reply = ResultIO.new
    self.class.notify_observers(:before_force_stop, {:application => self, :reply => reply, :dependency => dependency})
    self.start_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.force_stop(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0 and throw_exception_on_failure)
    end
    self.class.notify_observers(:after_force_stop, {:application => self, :reply => reply, :dependency => dependency})
    reply    
  end
  
  # Restart a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge to restart. Set to nil for all dependencies.
  def restart(dependency=nil)
    reply = ResultIO.new
    self.class.notify_observers(:before_restart, {:application => self, :reply => reply, :dependency => dependency})
    self.start_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.restart(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)
    end
    self.class.notify_observers(:after_restart, {:application => self, :reply => reply, :dependency => dependency})
    reply    
  end
  
  # Reload a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge to reload. Set to nil for all dependencies.
  def reload(dependency=nil)
    reply = ResultIO.new
    self.class.notify_observers(:before_reload, {:application => self, :reply => reply, :dependency => dependency})
    self.start_order.each do |comp_inst_name|
      comp_inst = self.comp_instance_map[comp_inst_name]
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.reload(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)
    end
    self.class.notify_observers(:after_reload, {:application => self, :reply => reply, :dependency => dependency})
    reply
  end
  
  # Retrieves status for a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge
  def status(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.status(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end
  
  # Invokes tidy for a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge
  def tidy(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.tidy(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end
  
  # Invokes threaddump for a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge
  def threaddump(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.threaddump(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end
  
  # Invokes system_messages for a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge  
  def system_messages(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)
      
      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.system_messages(comp_inst)
      end
      
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end

  # Invokes expose_port for a particular dependency on all gears that host it.
  # @param [String] dependency Name of a cartridge
  def expose_port(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)

      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.expose_port(comp_inst)
      end

      raise f[0][:exception] if(f.length > 0)
    end
    reply
  end

  def conceal_port(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)

      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.conceal_port(comp_inst)
      end
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end
  
  def show_port(dependency=nil)
    reply = ResultIO.new
    self.comp_instance_map.each do |comp_inst_name, comp_inst|
      next if !dependency.nil? and (comp_inst.parent_cart_name != dependency)

      group_inst = self.group_instance_map[comp_inst.group_instance_name]
      s,f = run_on_gears(group_inst.gears, reply, false) do |gear, r|
        r.append gear.show_port(comp_inst)
      end
      raise f[0][:exception] if(f.length > 0)      
    end
    reply
  end
  
  def add_authorized_ssh_key(ssh_key, key_type=nil, comment=nil)
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.add_authorized_ssh_key(ssh_key, key_type, comment)
    end
    raise f[0][:exception] if(f.length > 0)    
    reply
  end
  
  def remove_authorized_ssh_key(ssh_key)
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.remove_authorized_ssh_key(ssh_key)
    end
    raise f[0][:exception] if(f.length > 0)    
    reply
  end
  
  def add_env_var(key, value)
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.add_env_var(key, value)
    end
    raise f[0][:exception] if(f.length > 0)  
    reply
  end
  
  def remove_env_var(key)
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.remove_env_var(key)
    end
    raise f[0][:exception] if(f.length > 0)    
    reply
  end
  
  def add_broker_key
    iv, token = Cloud::Sdk::AuthService.instance.generate_broker_key(self)
    iv = Base64::encode64(iv).gsub("\n", '')
    token = Base64::encode64(token).gsub("\n", '')
    
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.add_broker_auth_key(iv,token)
    end
    raise f[0][:exception] if(f.length > 0)    
    reply
  end
  
  def remove_broker_key
    reply = ResultIO.new
    s,f = run_on_gears(nil,reply,false) do |gear,r|
      r.append gear.remove_broker_auth_key
    end
    raise f[0][:exception] if(f.length > 0)    
    reply
  end
  
  def add_system_ssh_keys(gears=nil)
    reply = ResultIO.new
    run_on_gears(gears,reply,false) do |gear,r|
      @user.system_ssh_keys.each do |key_name, key_info|
        r.append gear.add_authorized_ssh_key(key_info, nil, key_name)
      end
    end if @user.system_ssh_keys
    reply
  end
  
  def add_ssh_keys(gears=nil)
    reply = ResultIO.new
    run_on_gears(gears,reply,false) do |gear,r|
      @user.ssh_keys.each do |key_name, key_info|
        r.append gear.add_authorized_ssh_key(key_info["key"], key_info["type"], key_name)
      end
    end if @user.ssh_keys
    reply
  end
  
  def add_system_env_vars(gears=nil)
    reply = ResultIO.new
    run_on_gears(gears,reply,false) do |gear,r|
      @user.env_vars.each do |key, value|
        r.append gear.add_env_var(key, value)
      end
    end if @user.env_vars
    reply
  end

  def add_dns(appname, namespace, public_hostname)
    dns = Cloud::Sdk::DnsService.instance
    begin
      dns.register_application(appname, namespace, public_hostname)
      dns.publish
    ensure
      dns.close
    end
  end
  
  def create_dns
    reply = ResultIO.new
    self.class.notify_observers(:before_create_dns, {:application => self, :reply => reply})    
    public_hostname = self.container.get_public_hostname
    add_dns(@name, @user.namespace, public_hostname)
    if false and self.scalable
      # add dns for web cart gears
      wb = web_cart
      # find the group instance where the web-cartridge is residing
      self.group_instance_map.keys.each { |ginst_name|
        next if not ginst_name.include? wb
        ginst = self.group_instance_map[ginst_name]
        ginst.gears.each { |gear|
          self.add_dns(gear.uuid[0..9], @user.namespace, gear.get_proxy.get_public_hostname)
        }
      }
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
      if self.scalable
        # add dns for web cart gears
        wb = web_cart
        # find the group instance where the web-cartridge is residing
        self.group_instance_map.keys.each { |ginst_name|
          next if not ginst_name.include? wb
          ginst = self.group_instance_map[ginst_name]
          ginst.gears.each { |gear|
            dns.deregister_application(gear.uuid[0..9],@user.namespace)
          }
        }
      end
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
  
  def add_alias(server_alias)
    self.aliases = [] unless self.aliases
    raise Cloud::Sdk::UserException.new("Alias '#{server_alias}' already exists for '#{@name}'", 255) if self.aliases.include? server_alias
    reply = ResultIO.new
    begin
      self.aliases.push(server_alias)
      self.save      
      reply.append self.container.add_alias(self, self.gear, self.framework, server_alias)
    rescue Exception => e
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.inspect
      reply.append self.container.remove_alias(self, self.gear, self.framework, server_alias)      
      self.aliases.delete(server_alias)
      self.save
      raise
    end
    reply
  end
  
  def remove_alias(server_alias)
    self.aliases = [] unless self.aliases
    reply = ResultIO.new
    begin
      reply.append self.container.remove_alias(self, self.gear, self.framework, server_alias)
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
    self.requires_feature << dep
    reply.append self.configure_dependencies

    self.class.notify_observers(:after_add_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end
  
  def remove_dependency(dep)
    reply = ResultIO.new
    self.class.notify_observers(:before_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    self.embedded = {} unless self.embedded
        
    raise Cloud::Sdk::UserException.new("#{dep} not embedded in '#{@name}', try adding it first", 101) unless self.embedded.include? dep
    self.requires_feature.delete(dep)
    reply.append self.configure_dependencies
    self.class.notify_observers(:after_remove_dependency, {:application => self, :dependency => dep, :reply => reply})
    reply
  end

  # Returns the first Gear object on which the application is running
  # @return [Gear]
  # @deprecated  
  def gear
    if self.group_instances.nil?
      elaborate_descriptor
    end
    
    if scalable
      self.group_instance_map.keys.each { |ginst_name|
        return self.group_instance_map[ginst_name].gears.first if ginst_name.include? self.proxy_cartridge
      }
    end

    group_instance = self.group_instances.first
    return nil unless group_instance
    
    return group_instance.gears.first
  end
  
  # Get the ApplicationContainerProxy object for the first gear the application is running on
  # @return [ApplicationContainerProxy]
  # @deprecated  
  def container
    return nil if self.gear.nil?
    return self.gear.get_proxy
  end
  
  # Get the name of framework cartridge in use by the application without the version suffix
  # @return [String]
  # @deprecated  
  def framework_cartridge  
    fcart = self.framework
    return fcart.split('-')[0..-2].join('-') unless fcart.nil?
    return nil
  end
  
  # Get the name of framework cartridge in use by the application
  # @return [String]
  # @deprecated  
  def framework
    return self.proxy_cartridge if self.scalable
    framework_carts = CartridgeCache.cartridge_names('standalone')
    self.requires_feature.each do |feature|
      if framework_carts.include? feature
        return feature 
      end
    end
    return nil
  end
  
  # Provide a list of direct dependencies of the application that are hosted on the same gear as the "framework" cartridge.
  # @return [Array<String>]
  # @deprecated  
  def embedded
    embedded_carts = CartridgeCache.cartridge_names('embedded')
    retval = {}
    self.comp_instance_map.values.each do |comp_inst|
      if embedded_carts.include?(comp_inst.parent_cart_name)
        retval[comp_inst.parent_cart_name] = {}
        retval[comp_inst.parent_cart_name] = {"info" => comp_inst.cart_data.first} unless comp_inst.cart_data.first.nil?
      end
    end
    retval
  end

  # Provide a way of updating the component information for a given cartridge
  # @deprecated
  def set_embedded_cart_info(cart_name, info)
    self.comp_instance_map.values.each do |comp_inst|
      comp_inst.cart_data = [info] if cart_name == comp_inst.parent_cart_name
    end
  end
  
  # Provides an array version of the component instance map for saving in the datastore.
  # @return [Array<Hash>]
  def comp_instances
    @comp_instance_map = {} if @comp_instance_map.nil?
    @comp_instance_map.values
  end
  
  # Rebuilds the component instance map from an array of hashes or objects
  # @param [Array<Hash>] data
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

  # Provides an array version of the group instance map for saving in the datastore.
  # @return [Array<Hash>]
  def group_instances
    @group_instance_map = {} if @group_instance_map.nil?
    values = @group_instance_map.values.uniq
    keys   = @group_instance_map.keys
    
    values.each do |group_inst|
      group_inst.reused_by = keys.clone.delete_if{ |k| @group_instance_map[k] != group_inst }
    end
    
    values
  end
  
  # Rebuilds the group instance map from an array of hashes or objects
  # @param [Array<Hash>] data
  def group_instances=(data)
    group_instance_map_will_change!    
    @group_instance_map = {} if @group_instance_map.nil?
    data.each do |value|
      if value.class == GroupInstance
        value.reused_by.each do |k|
          @group_instance_map[k] = value
        end
      else
        ginst = GroupInstance.new(self)
        ginst.attributes=value
        ginst.reused_by.each do |k|
          @group_instance_map[k] = ginst
        end
      end
    end
  end
   
  def get_name_prefix
    return "@@app"
  end

  # Parse the descriptor and build or update the runtime descriptor structure
  def elaborate_descriptor
    self.group_instance_map = {} if group_instance_map.nil?
    self.comp_instance_map = {} if comp_instance_map.nil?
    self.working_comp_inst_hash = {}
    self.working_group_inst_hash = {}
    self.group_override_map = {} 
    self.conn_endpoints_list = [] 
    default_profile = @profile_name_map[@default_profile]
    
    generate_group_overrides(default_profile)
  
    default_profile.groups.each { |g|
      #gpath = self.name + "." + g.name
      gpath = self.get_name_prefix + g.get_name_prefix
      mapped_path = group_override_map[gpath] || ""
      gi = working_group_inst_hash[mapped_path]
      if gi.nil?
        gi = self.group_instance_map[gpath]
        if gi.nil?
          gi = GroupInstance.new(self, self.name, self.default_profile, g.name, gpath) 
        else
          gi.merge(self.name, self.default_profile, g.name, gpath)
        end
      else
        gi.merge(self.name, self.default_profile, g.name, gpath)
      end
      self.group_instance_map[gpath] = gi
      self.working_group_inst_hash[gpath] = gi
      gi.elaborate(default_profile, g, self.get_name_prefix, self)
    }
    
    # make connection_endpoints out of provided connections
    default_profile.connections.each { |conn|
      inst1 = ComponentInstance::find_component_in_cart(default_profile, self, conn.components[0], self.get_name_prefix)
      inst2 = ComponentInstance::find_component_in_cart(default_profile, self, conn.components[1], self.get_name_prefix)
      ComponentInstance::establish_connections(inst1, inst2, self)
    }
    # check self.comp_instance_map for component instances
    # check self.group_instance_map for group instances
    # check self.conn_endpoints_list for list of connection endpoints (fully resolved)
  
    # auto merge top groups
    auto_merge_top_groups(default_profile)
  
    # resolve group co-locations
    colocate_groups
    
    # get configure_order and start_order
    get_exec_order(default_profile)
  
    deleted_components_list = []
    self.comp_instance_map.each { |k,v| deleted_components_list << k if self.working_comp_inst_hash[k].nil?  }
    deleted_components_list
  end
  
private

  def cleanup_deleted_components
    # delete entries in {group,comp}_instance_map that do 
    # not exist in working_{group,comp}_inst_hash
    self.group_instance_map.delete_if { |k,v| 
      v.component_instances.delete(k) if self.working_comp_inst_hash[k].nil? and v.component_instances.include?(k)
      self.working_group_inst_hash[k].nil? 
    }
    self.comp_instance_map.delete_if { |k,v| self.working_comp_inst_hash[k].nil?  }
  end
  
  def get_exec_order(default_profile)
    self.configure_order = []
    self.start_order = []
    cpath = self.get_name_prefix + default_profile.groups.first.component_refs.first.get_name_prefix(default_profile)
    cinst = self.comp_instance_map[cpath]
    ComponentInstance::collect_exec_order(self, cinst, self.configure_order)
    ComponentInstance::collect_exec_order(self, cinst, self.start_order)
    self.configure_order << cpath
    self.start_order << cpath
  end
  
  def colocate_groups
    self.conn_endpoints_list.each { |conn|
      if conn.from_connector.type.match(/^FILESYSTEM/) or conn.from_connector.type.match(/^AFUNIX/)
        cinst1 = self.comp_instance_map[conn.from_comp_inst]
        ginst1 = self.group_instance_map[cinst1.group_instance_name]
        cinst2 = self.comp_instance_map[conn.to_comp_inst]
        ginst2 = self.group_instance_map[cinst2.group_instance_name]
        next if ginst1==ginst2
        # these two group instances need to be colocated
        #ginst1.merge(ginst2.cart_name, ginst2.profile_name, ginst2.group_name, ginst2.name, ginst2.component_instances)
        ginst1.merge_inst(ginst2)
        self.group_instance_map[cinst2.group_instance_name] = ginst1
      end
    }
  end
  
  def generate_group_overrides(default_profile)
    if not default_profile.group_overrides.empty?
      default_profile.group_overrides.each do |n, v|
        from = self.get_name_prefix + n
        to = self.get_name_prefix + v
        self.group_override_map[from] = to
      end
    else
      default_profile = @profile_name_map[@default_profile]
      first_group = default_profile.groups[0]
      default_profile.groups.each do |g|
        next if first_group==g
        self.group_override_map[self.get_name_prefix + g.get_name_prefix] = self.get_name_prefix + first_group.get_name_prefix
      end
    end
  end
  
  def auto_merge_top_groups(default_profile)
    return if self.scalable
    first_group = default_profile.groups[0]
    gpath = self.get_name_prefix + first_group.get_name_prefix
    gi = self.group_instance_map[gpath]
    first_group.component_refs.each { |comp_ref|
      cpath = self.get_name_prefix + comp_ref.get_name_prefix(default_profile)
      ci = self.comp_instance_map[cpath]
      ci.dependencies.each { |cdep|
        cdepinst = self.comp_instance_map[cdep]
        ginst = self.group_instance_map[cdepinst.group_instance_name]
        next if ginst==gi
        Rails.logger.debug "Auto-merging group #{ginst.name} into #{gi.name}"
        # merge ginst into gi
        #gi.merge(ginst.cart_name, ginst.profile_name, ginst.group_name, ginst.name, ginst.component_instances)
        gi.merge_inst(ginst)
        self.group_instance_map[cdepinst.group_instance_name] = gi
      }
    }
  end


  # Runs the provided block on a set of containers
  # @param [Array<Gear>] Array of containers to run the block on. If nil, will run on all containers.
  # @param [Boolean] fail_fast Stop running immediately if an exception is raised
  # @param [Block]
  # @return [<successful_runs, failed_runs>] List of containers where the runs succeeded/failed
  def run_on_gears(gears=nil, result_io = nil, fail_fast=true, &block)
    successful_runs = []
    failed_runs = []
    gears = self.group_instances.uniq.map{ |ginst| ginst.gears }.flatten if gears.nil?
    
    gears.each do |gear|
      begin
        retval = block.call(gear, result_io)
        successful_runs.push({:gear => gear, :return => retval})
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.inspect
        Rails.logger.error e.backtrace.inspect        
        failed_runs.push({:gear => gear, :exception => e})
        if (!result_io.nil? && e.kind_of?(Cloud::Sdk::CdkException) && !e.resultIO.nil?)
          result_io.append(e.resultIO)
        end
        if fail_fast
          raise Exception.new({:succesful => successful_runs, :failed => failed_runs, :exception => e})
        end
      end
    end
    
    return successful_runs, failed_runs
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
