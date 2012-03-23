require 'mcollective'
require 'openshift'
require 'express/broker/nurture'
require 'express/broker/apptegic'
require 'open-uri'

include MCollective::RPC
module Express
  module Broker
    class ApplicationContainerProxy
      @@C_CONTROLLER = 'stickshift-node'
      attr_accessor :id, :district
      
      def initialize(id, district=nil)
        @id = id
        @district = district
      end
      
      def self.find_available_impl(node_profile=nil, district_uuid=nil)
        district = nil
        if Rails.configuration.districts[:enabled] && (!district_uuid || district_uuid == 'NONE')  
          district = District.find_available(node_profile)
          if district
            district_uuid = district.uuid
            Rails.logger.debug "DEBUG: find_available_impl: district_uuid: #{district_uuid}"
          elsif Rails.configuration.districts[:require_for_app_create]
            raise StickShift::NodeException.new("No district nodes available.  If the problem persists please contact Red Hat support.", 140)
          end
        end
        current_server, current_capacity = rpc_find_available(node_profile, district_uuid)
        Rails.logger.debug "CURRENT SERVER: #{current_server}"
        if !current_server
          current_server, current_capacity = rpc_find_available(node_profile, district_uuid, true)
          Rails.logger.debug "CURRENT SERVER: #{current_server}"
        end
        raise StickShift::NodeException.new("No nodes available.  If the problem persists please contact Red Hat support.", 140) unless current_server
        Rails.logger.debug "DEBUG: find_available_impl: current_server: #{current_server}: #{current_capacity}"

        ApplicationContainerProxy.new(current_server, district)
      end
      
      def self.find_one_impl(node_profile=nil)
        current_server = rpc_find_one(node_profile)
        Rails.logger.debug "CURRENT SERVER: #{current_server}"
        raise StickShift::NodeException.new("No nodes found.  If the problem persists please contact Red Hat support.", 140) unless current_server
        Rails.logger.debug "DEBUG: find_one_impl: current_server: #{current_server}"

        ApplicationContainerProxy.new(current_server)
      end

      def self.blacklisted_in_impl?(name)
        OpenShift::Blacklist.in_blacklist?(name)
      end
      
      def get_available_cartridges
        result = execute_direct(@@C_CONTROLLER, 'cartridge-list', "--porcelain --with-descriptors", false)
        result = parse_result(result)
        cart_data = JSON.parse(result.resultIO.string)
        cart_data.map! {|c| StickShift::Cartridge.new.from_descriptor(YAML.load(c))}
      end
      
      def reserve_uid(district_uuid=nil)
        reserved_uid = nil
        if Rails.configuration.districts[:enabled]
          if @district
            district_uuid = @district.uuid
          else
            district_uuid = get_district_uuid unless district_uuid
          end
          if district_uuid && district_uuid != 'NONE'
            reserved_uid = StickShift::DataStore.instance.reserve_district_uid(district_uuid)
            raise StickShift::SSException.new("uid could not be reserved") unless reserved_uid
          end
        end
        reserved_uid
      end
      
      def unreserve_uid(uid, district_uuid=nil)
        if Rails.configuration.districts[:enabled]
          if @district
            district_uuid = @district.uuid
          else
            district_uuid = get_district_uuid unless district_uuid
          end
          if district_uuid && district_uuid != 'NONE'
            StickShift::DataStore.instance.unreserve_district_uid(district_uuid, uid)
          end
        end
      end
      
      def inc_externally_reserved_uids_size(district_uuid=nil)
        if Rails.configuration.districts[:enabled]
          if @district
            district_uuid = @district.uuid
          else
            district_uuid = get_district_uuid unless district_uuid
          end
          if district_uuid && district_uuid != 'NONE'
            StickShift::DataStore.instance.inc_district_externally_reserved_uids_size(district_uuid)
          end
        end
      end
      
      def create(app, gear, quota_blocks=nil, quota_files=nil)
        result = nil
        (1..10).each do |i|
          cmd = "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}'"
          cmd += " -i '#{gear.uid}'" if gear.uid
          cmd += " --named '#{app.name}'" if app.name
          cmd += " --with-quota-blocks '#{quota_blocks}'" if quota_blocks
          cmd += " --with-quota-files '#{quota_files}'" if quota_files
          cmd += " --with-namespace '#{app.user.namespace}'"
          mcoll_reply = execute_direct(@@C_CONTROLLER, 'app-create', cmd)
          result = parse_result(mcoll_reply)
          if result.exitcode == 129 && has_uid_or_gid?(app.gear.uid) # Code to indicate uid already taken
            destroy(app, gear, true)
            inc_externally_reserved_uids_size
            gear.uid = reserve_uid
            app.save
          else
            break
          end
        end
        result
      end
    
      def destroy(app, gear, keep_uid=false, uid=nil)
        result = execute_direct(@@C_CONTROLLER, 'app-destroy', "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}'")
        result_io = parse_result(result)
        
        uid = gear.uid unless uid
        
        if uid && !keep_uid
          unreserve_uid(uid)
        end
        return result_io
      end

      def add_authorized_ssh_key(app, gear, ssh_key, key_type=nil, message=nil)
        cmd = "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -s '#{ssh_key}'"
        cmd += " -t '#{key_type}'" if key_type
        cmd += " -m '-#{message}'" if message
        result = execute_direct(@@C_CONTROLLER, 'authorized-ssh-key-add', cmd)
        parse_result(result)
      end

      def remove_authorized_ssh_key(app, gear, ssh_key, comment=nil)
        cmd = "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -s '#{ssh_key}'"
        cmd += " -m '-#{comment}'" if comment
        result = execute_direct(@@C_CONTROLLER, 'authorized-ssh-key-remove', cmd)
        parse_result(result)
      end

      def add_env_var(app, gear, key, value)
        result = execute_direct(@@C_CONTROLLER, 'env-var-add', "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -k '#{key}' -v '#{value}'")
        parse_result(result)
      end
      
      def remove_env_var(app, gear, key)
        result = execute_direct(@@C_CONTROLLER, 'env-var-remove', "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -k '#{key}'")
        parse_result(result)
      end
    
      def add_broker_auth_key(app, gear, iv, token)
        result = execute_direct(@@C_CONTROLLER, 'broker-auth-key-add', "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -i '#{iv}' -t '#{token}'")
        parse_result(result)
      end
    
      def remove_broker_auth_key(app, gear)
        result = execute_direct(@@C_CONTROLLER, 'broker-auth-key-remove', "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}'")
        parse_result(result)
      end
      
      def preconfigure_cartridge(app, gear, cart)
        if framework_carts.include? cart
          run_cartridge_command(cart, app, gear, "preconfigure")
        else
          #no-op
          ResultIO.new
        end
      end
      
      def configure_cartridge(app, gear, cart, template_git_url=nil)
        result_io = ResultIO.new
        cart_data = nil
                  
        if framework_carts.include? cart
          result_io = run_cartridge_command(cart, app, gear, "configure", template_git_url)
        elsif embedded_carts.include? cart
          result_io, cart_data = add_component(app,gear,cart)
        else
          #no-op
        end
        
        return result_io, cart_data
      end
      
      def deconfigure_cartridge(app, gear, cart)
        if framework_carts.include? cart
          run_cartridge_command(cart, app, gear, "deconfigure")
        elsif embedded_carts.include? cart
          remove_component(app,gear,cart)
        else
          ResultIO.new
        end        
      end
      
      def get_public_hostname
        rpc_get_fact_direct('public_hostname')
      end
      
      def get_capacity
        rpc_get_fact_direct('capacity').to_i
      end
      
      def get_active_capacity
        rpc_get_fact_direct('active_capacity').to_i
      end
      
      def get_district_uuid
        rpc_get_fact_direct('district_uuid')
      end
      
      def get_ip_address
        rpc_get_fact_direct('ipaddress')
      end
      
      def get_node_profile
        rpc_get_fact_direct('node_profile')
      end

      def execute_connector(app, gear, cart, connector_name, input_args)
        mcoll_reply = execute_direct(@@C_CONTROLLER, 'connector-execute', "--gear-uuid '#{gear.uuid}' --cart-name '#{cart}' --hook-name '#{connector_name}' " + input_args.join(" "))
        if mcoll_reply and mcoll_reply.length>0
          mcoll_reply = mcoll_reply[0]
          output = mcoll_reply.results[:data][:output]
          exitcode = mcoll_reply.results[:data][:exitcode]
          return [output, exitcode]
        end
        [nil, nil]
      end
      
      def start(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "start")
        elsif embedded_carts.include? cart
          start_component(app, gear, cart)
        else
          ResultIO.new
        end
      end
      
      def stop(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "stop")
        elsif embedded_carts.include? cart
          stop_component(app, gear, cart)
        else
          ResultIO.new          
        end
      end
      
      def force_stop(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "force-stop")
        else
          ResultIO.new          
        end          
      end
      
      def restart(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "restart")
        elsif embedded_carts.include? cart
          restart_component(app, gear, cart)
        else
          ResultIO.new                  
        end
      end
      
      def reload(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "reload")
        elsif embedded_carts.include? cart
          reload_component(app, gear, cart)
        else
          ResultIO.new          
        end
      end
      
      def status(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "status")
        elsif embedded_carts.include? cart
          component_status(app, gear, cart)
        else
          ResultIO.new          
        end
      end
      
      def tidy(app, gear, cart)
        if framework_carts.include?(cart)        
          run_cartridge_command(cart, app, gear, "tidy") 
        else
          ResultIO.new
        end
      end
      
      def threaddump(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "threaddump")
        else
          ResultIO.new
        end          
      end
      
      def system_messages(app, gear, cart)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "system-messages")
        else
          ResultIO.new
        end          
      end
      
      def expose_port(app, gear, cart)
        run_cartridge_command(cart, app, gear, "expose-port")
      end

      def conceal_port(app, gear, cart)
        run_cartridge_command(cart, app, gear, "conceal-port")
      end

      def show_port(app, gear, cart)
        run_cartridge_command(cart, app, gear, "show-port")
      end

      def add_alias(app, gear, cart, server_alias)
        if framework_carts.include?(cart)
          run_cartridge_command(cart, app, gear, "add-alias", server_alias)
        else
          ResultIO.new
        end
      end
      
      def remove_alias(app, gear, cart, server_alias)
        if framework_carts.include?(cart)        
          run_cartridge_command(cart, app, gear, "remove-alias", server_alias)
        else
          ResultIO.new
        end
      end
      
      def update_namespace(app, cart, new_ns, old_ns)
        mcoll_reply = execute_direct(cart, 'update-namespace', "#{app.name} #{new_ns} #{old_ns} #{app.uuid}")
        parse_result(mcoll_reply)
      end
      
      def move_app(app, destination_container, destination_district_uuid=nil, allow_change_district=false, node_profile=nil)
        source_container = app.container

        if node_profile
          app.gear.node_profile = node_profile
        end

        source_district_uuid = source_container.get_district_uuid
        if destination_container.nil?
          unless allow_change_district
            if destination_district_uuid && destination_district_uuid != source_district_uuid
              raise StickShift::UserException.new("Error moving app.  Cannot change district from '#{source_district_uuid}' to '#{destination_district_uuid}' without allow_change_district flag.", 1)
            else
              destination_district_uuid = source_district_uuid unless source_district_uuid == 'NONE'
            end
          end
          destination_container = ApplicationContainerProxy.find_available_impl(app.gear.node_profile, destination_district_uuid)
          log_debug "DEBUG: Destination container: #{destination_container.id}"
          destination_district_uuid = destination_container.get_district_uuid
        else
          if destination_district_uuid
            log_debug "DEBUG: Destination district uuid '#{destination_district_uuid}' is being ignored in favor of destination container #{destination_container.id}"
          end
          destination_district_uuid = destination_container.get_district_uuid
          unless allow_change_district || (source_district_uuid == destination_district_uuid)
            raise StickShift::UserException.new("Resulting move would change districts from '#{source_district_uuid}' to '#{destination_district_uuid}'", 1)
          end
        end
        
        log_debug "DEBUG: Source district uuid: #{source_district_uuid}"
        log_debug "DEBUG: Destination district uuid: #{destination_district_uuid}"
        keep_uid = destination_district_uuid == source_district_uuid && destination_district_uuid && destination_district_uuid != 'NONE'
        log_debug "DEBUG: District unchanged keeping uid" if keep_uid

        if source_container.id == destination_container.id
          raise StickShift::UserException.new("Error moving app.  Old and new servers are the same: #{source_container.id}", 1)
        end
        
        orig_uid = app.gear.uid

        log_debug "DEBUG: Moving app '#{app.name}' with uuid #{app.gear.uuid} from #{source_container.id} to #{destination_container.id}"
        
        url = "http://#{app.name}-#{app.user.namespace}.#{Rails.configuration.ss[:domain_suffix]}"
        
        reply = ResultIO.new
        leave_stopped = false
        idle = false
        quota_blocks = nil
        quota_files = nil
        log_debug "DEBUG: Getting existing app '#{app.name}' status before moving"
        do_with_retry('status') do
          result = source_container.status(app, app.gear, app.framework)
          result.cart_commands.each do |command_item|
            case command_item[:command]
            when "ATTR"
              key = command_item[:args][0]
              value = command_item[:args][1]
              if key == 'status'
                case value
                when "ALREADY_STOPPED"
                  leave_stopped = true
                when "ALREADY_IDLED"
                  leave_stopped = true
                  idle = true
                end
              elsif key == 'quota_blocks'
                quota_blocks = value
              elsif key == 'quota_files'
                quota_files = value
              end
            end
            reply.append result
          end
        end
        
        if idle
          log_debug "DEBUG: App '#{app.name}' was idle"
        elsif leave_stopped
          log_debug "DEBUG: App '#{app.name}' was stopped"
        else
          log_debug "DEBUG: App '#{app.name}' was running"
        end

        unless leave_stopped
          log_debug "DEBUG: Accessing url: #{url}"
          begin
            open(url) do |resp|
              log_debug "\nStatus Code: #{resp.status[0]} - #{resp.status[1]}"
              log_debug "\n####################### Body Begin ###########################"
              log_debug resp.read
              log_debug "######################## Body End ############################\n"
            end
          rescue Exception => e
            log_debug "DEBUG: Error accessing URL: #{e.message}"
          end
        else
          log_debug "DEBUG: Not accessing url since application was stopped"
        end

        begin
          unless leave_stopped
            log_debug "DEBUG: Stopping existing app '#{app.name}' before moving"
            do_with_retry('stop') do
              reply.append source_container.stop(app, app.gear, app.framework)
            end
          end

          log_debug "DEBUG: Force stopping existing app '#{app.name}' before moving"
          do_with_retry('force-stop') do
            reply.append source_container.force_stop(app, app.gear, app.framework)
          end

          begin
            unless app.embedded.nil? || keep_uid
              app.embedded.each do |cart, cart_info|
                log_debug "DEBUG: Performing cartridge level pre-move for embedded #{cart} for '#{app.name}' on #{source_container.id}"
                reply.append source_container.send(:run_cartridge_command, "embedded/" + cart, app, app.gear, "pre-move", nil, false)
              end
            end

            begin
              unless keep_uid
                app.gear.uid = destination_container.reserve_uid(destination_district_uuid)
                log_debug "DEBUG: Reserved uid '#{app.gear.uid}' on district: '#{destination_district_uuid}'"
              end
              log_debug "DEBUG: Creating new account for app '#{app.name}' on #{destination_container.id}"
              reply.append destination_container.create(app, app.gear, quota_blocks, quota_files)
  
              log_debug "DEBUG: Moving content for app '#{app.name}' to #{destination_container.id}"
              log_debug `eval \`ssh-agent\`; ssh-add /var/www/stickshift/broker/config/keys/rsync_id_rsa; ssh -o StrictHostKeyChecking=no -A root@#{source_container.get_ip_address} "rsync -aA#{(app.gear.uid && app.gear.uid == orig_uid) ? 'X' : ''} -e 'ssh -o StrictHostKeyChecking=no' /var/lib/stickshift/#{app.gear.uuid}/ root@#{destination_container.get_ip_address}:/var/lib/stickshift/#{app.gear.uuid}/"`
              if $?.exitstatus != 0
                raise StickShift::NodeException.new("Error moving app '#{app.name}' from #{source_container.id} to #{destination_container.id}", 143)
              end
  
              begin
                log_debug "DEBUG: Performing cartridge level move for '#{app.name}' on #{destination_container.id}"
                reply.append destination_container.send(:run_cartridge_command, app.framework, app, app.gear, "move", idle ? '--idle' : nil, false)
                unless app.embedded.nil?
                  app.embedded.each do |cart, cart_info|
                    log_debug "DEBUG: Performing cartridge level move for embedded #{cart} for '#{app.name}' on #{destination_container.id}"
                    embedded_reply = destination_container.send(:run_cartridge_command, "embedded/" + cart, app, app.gear, "move", nil, false)
                    component_details = embedded_reply.appInfoIO.string
                    unless component_details.empty?
                      app.set_embedded_cart_info(cart, component_details)
                    end
                    reply.append embedded_reply
                    unless keep_uid
                      log_debug "DEBUG: Performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{destination_container.id}"
                      reply.append destination_container.send(:run_cartridge_command, "embedded/" + cart, app, app.gear, "post-move", nil, false)
                    end
                  end
                end

                unless app.aliases.nil?
                  app.aliases.each do |server_alias|
                    reply.append destination_container.send(:run_cartridge_command, app.framework, app, app.gear, "add-alias", server_alias, false)
                  end
                end
                
                unless leave_stopped
                  log_debug "DEBUG: Starting '#{app.name}' after move on #{destination_container.id}"
                  do_with_retry('start') do
                    reply.append destination_container.send(:run_cartridge_command, app.framework, app, app.gear, "start", nil, false)
                  end
                end
                
                log_debug "DEBUG: Fixing DNS and mongo for app '#{app.name}' after move"
                log_debug "DEBUG: Changing server identity of '#{app.name}' from '#{source_container.id}' to '#{destination_container.id}'"
                app.gear.server_identity = destination_container.id
                app.gear.container = destination_container
                reply.append app.recreate_dns
                app.save
              rescue Exception => e
                begin
                  log_debug "DEBUG: Moving failed.  Rolling back '#{app.name}' with remove-httpd-proxy on '#{destination_container.id}'"
                  reply.append destination_container.send(:run_cartridge_command, app.framework, app, app.gear, "remove-httpd-proxy", nil, false)
                ensure
                  raise
                end
              end
            rescue Exception => e
              begin
                log_debug "DEBUG: Moving failed.  Rolling back '#{app.name}' with destroy on '#{destination_container.id}'"
                reply.append destination_container.destroy(app, app.gear, keep_uid)
              ensure
                raise
              end
            end
          rescue Exception => e
            begin
              unless keep_uid
                app.embedded.each do |cart, cart_info|
                  begin
                    log_debug "DEBUG: Performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{source_container.id}"
                    reply.append source_container.send(:run_cartridge_command, "embedded/" + cart, app, app.gear, "post-move", nil, false)
                  rescue Exception => e
                    log_error "ERROR: Error performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{source_container.id}: #{e.message}"
                  end
                end
              end
            ensure
              raise
            end
          end
        rescue Exception => e
          begin
            unless leave_stopped
              reply.append source_container.run_cartridge_command(app.framework, app, app.gear, "start", nil, false)
            end
          ensure
            raise
          end
        ensure
          log_debug "URL: #{url}"
        end

        log_debug "DEBUG: Deconfiguring old app '#{app.name}' on #{source_container.id} after move"
        begin
          do_with_retry('destroy') do
            begin
              reply.append source_container.run_cartridge_command(app.framework, app, app.gear, "deconfigure", nil, false)
            ensure
              reply.append source_container.destroy(app, app.gear, keep_uid, orig_uid)
            end
          end
        rescue Exception => e
          log_debug "DEBUG: The application '#{app.name}' with uuid '#{app.gear.uuid}' is now moved to '#{source_container.id}' but not completely deconfigured from '#{destination_container.id}'"
          raise
        end
        log_debug "Successfully moved '#{app.name}' with uuid '#{app.gear.uuid}' from '#{source_container.id}' to '#{destination_container.id}'"
        reply
      end
      
      #
      # Execute an RPC call for the specified agent.
      # If a server is supplied, only execute for that server.
      #
      def self.rpc_exec(agent, server=nil, forceRediscovery=false, options=rpc_options)
        if server
          Rails.logger.debug("DEBUG: rpc_exec: Filtering rpc_exec to server #{server}")
          # Filter to the specified server
          options[:filter]["identity"] = server
          options[:mcollective_limit_targets] = "1"
        end
      
        # Setup the rpc client
        rpc_client = rpcclient(agent, :options => options)
        if forceRediscovery
          rpc_client.reset
        end
        Rails.logger.debug("DEBUG: rpc_exec: rpc_client=#{rpc_client}")
      
        # Execute a block and make sure we disconnect the client
        begin
          result = yield rpc_client
        ensure
          rpc_client.disconnect
        end

        raise StickShift::NodeException.new("Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", 143) unless result

        result
      end
      
      def set_district(uuid, active)
        mc_args = { :uuid => uuid,
                    :active => active}
        rpc_client = rpc_exec_direct('libra')
        result = nil
        begin
          Rails.logger.debug "DEBUG: rpc_client.custom_request('set_district', #{mc_args.inspect}, @id, {'identity' => @id})"
          result = rpc_client.custom_request('set_district', mc_args, @id, {'identity' => @id})
          Rails.logger.debug "DEBUG: #{result.inspect}"
        ensure
          rpc_client.disconnect
        end
        Rails.logger.debug result.inspect
        result
      end
      
      protected
      
      def do_with_retry(action, num_tries=2)
        (1..num_tries).each do |i|
          begin
            yield
            if (i > 1)
              log_debug "DEBUG: Action '#{action}' succeeded on try #{i}.  You can ignore previous error messages or following mcollective debug related to '#{action}'"
            end
            break
          rescue Exception => e
            log_debug "DEBUG: Error performing #{action} on existing app on try #{i}: #{e.message}"
            raise if i == num_tries
          end
        end
      end
      
      def framework_carts
        @framework_carts ||= CartridgeCache.cartridge_names('standalone')
      end
      
      def embedded_carts
        @embedded_carts ||= CartridgeCache.cartridge_names('embedded')
      end
      
      def add_component(app, gear, component)
        reply = ResultIO.new
        begin
          reply.append run_cartridge_command('embedded/' + component, app, gear, 'configure')
        rescue Exception => e
          begin
            Rails.logger.debug "DEBUG: Failed to embed '#{component}' in '#{app.name}' for user '#{app.user.login}'"
            reply.debugIO << "Failed to embed '#{component} in '#{app.name}'"
            reply.append run_cartridge_command('embedded/' + component, app, gear, 'deconfigure')
          ensure
            raise
          end
        end
        
        component_details = reply.appInfoIO.string.empty? ? '' : reply.appInfoIO.string
        reply.debugIO << "Embedded app details: #{component_details}"
        [reply, component_details]
      end
      
      def remove_component(app, gear, component)
        Rails.logger.debug "DEBUG: Deconfiguring embedded application '#{component}' in application '#{app.name}' on node '#{@id}'"
        return run_cartridge_command('embedded/' + component, app, gear, 'deconfigure')
      end
      
      def start_component(app, gear, component)
        run_cartridge_command('embedded/' + component, app, gear, "start")
      end
      
      def stop_component(app, gear, component)
        run_cartridge_command('embedded/' + component, app, gear, "stop")
      end
      
      def restart_component(app, gear, component)
        run_cartridge_command('embedded/' + component, app, gear, "restart")    
      end
      
      def reload_component(app, gear, component)
        run_cartridge_command('embedded/' + component, app, gear, "reload")    
      end
      
      def component_status(app, gear, component)
        run_cartridge_command('embedded/' + component, app, gear, "status")    
      end
      
      def log_debug(message)
        Rails.logger.debug message
        puts message
      end
      
      def log_error(message)
        Rails.logger.error message
        puts message
      end
      
      def execute_direct(cartridge, action, args, log_debug_output=true)
          mc_args = { :cartridge => cartridge,
                      :action => action,
                      :args => args }
          rpc_client = rpc_exec_direct('libra')
          result = nil
          begin
            Rails.logger.debug "DEBUG: rpc_client.custom_request('cartridge_do', mc_args.inspect, @id, {'identity' => @id})"
            result = rpc_client.custom_request('cartridge_do', mc_args, @id, {'identity' => @id})
            Rails.logger.debug "DEBUG: #{result.inspect}" if log_debug_output
          ensure
            rpc_client.disconnect
          end
          result
      end
      
      def parse_result(mcoll_reply, app=nil, command=nil)
        result = ResultIO.new
        
        mcoll_result = mcoll_reply[0]
        output = nil
        if (mcoll_result && defined? mcoll_result.results && mcoll_result.results.has_key?(:data))
          output = mcoll_result.results[:data][:output]
          result.exitcode = mcoll_result.results[:data][:exitcode]
        else
          server_identity = app ? ApplicationContainerProxy.find_app(app.uuid, app.name) : nil
          if server_identity && @id != server_identity
            raise StickShift::InvalidNodeException.new("Node execution failure (invalid  node).  If the problem persists please contact Red Hat support.", 143, nil, server_identity)
          else
            raise StickShift::NodeException.new("Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", 143)
          end
        end
        
        if output && !output.empty?
          output.each_line do |line|
            if line =~ /^CLIENT_(MESSAGE|RESULT|DEBUG|ERROR): /
              if line =~ /^CLIENT_MESSAGE: /
                result.messageIO << line['CLIENT_MESSAGE: '.length..-1]
              elsif line =~ /^CLIENT_RESULT: /
                result.resultIO << line['CLIENT_RESULT: '.length..-1]
              elsif line =~ /^CLIENT_DEBUG: /
                result.debugIO << line['CLIENT_DEBUG: '.length..-1]
              else
                result.errorIO << line['CLIENT_ERROR: '.length..-1]
              end
            elsif line =~ /^CART_DATA: /
              result.data << line['CART_DATA: '.length..-1]
            elsif line =~ /^APP_INFO: /
              result.appInfoIO << line['APP_INFO: '.length..-1]
            elsif result.exitcode == 0
              if line =~ /^SSH_KEY_(ADD|REMOVE): /
                if line =~ /^SSH_KEY_ADD: /
                  key = line['SSH_KEY_ADD: '.length..-1].chomp
                  result.cart_commands.push({:command => "SYSTEM_SSH_KEY_ADD", :args => [key]})
                else
                  result.cart_commands.push({:command => "SYSTEM_SSH_KEY_REMOVE", :args => []})
                end
              elsif line =~ /^ENV_VAR_(ADD|REMOVE): /
                if line =~ /^ENV_VAR_ADD: /
                  env_var = line['ENV_VAR_ADD: '.length..-1].chomp.split('=')
                  result.cart_commands.push({:command => "ENV_VAR_ADD", :args => [env_var[0], env_var[1]]})
                else
                  key = line['ENV_VAR_REMOVE: '.length..-1].chomp
                  result.cart_commands.push({:command => "ENV_VAR_REMOVE", :args => [key]})
                end
              elsif line =~ /^BROKER_AUTH_KEY_(ADD|REMOVE): /
                if line =~ /^BROKER_AUTH_KEY_ADD: /
                  result.cart_commands.push({:command => "BROKER_KEY_ADD", :args => []})
                else
                  result.cart_commands.push({:command => "BROKER_KEY_REMOVE", :args => []})
                end
              elsif line =~ /^ATTR: /
                attr = line['ATTR: '.length..-1].chomp.split('=')
                result.cart_commands.push({:command => "ATTR", :args => [attr[0], attr[1]]})
              else
                #result.debugIO << line
              end
            else # exitcode != 0
              result.debugIO << line
              Rails.logger.debug "DEBUG: server results: " + line
            end
          end
        end
        result
      end
      
      #
      # Returns the server identity of the specified app
      #
      def self.find_app(app_uuid, app_name)
        server_identity = nil
        rpc_exec('libra') do |client|
          client.has_app(:uuid => app_uuid,
                         :application => app_name) do |response|
            output = response[:body][:data][:output]
            if output == true
              server_identity = response[:senderid]
            end
          end
        end
        return server_identity
      end
      
      #
      # Returns whether this server has the specified app
      #
      def has_app?(app_uuid, app_name)
        ApplicationContainerProxy.rpc_exec('libra', @id) do |client|
          client.has_app(:uuid => app_uuid,
                         :application => app_name) do |response|
            output = response[:body][:data][:output]
            return output == true
          end
        end
      end
      
      #
      # Returns whether this server has the specified embedded app
      #
      def has_embedded_app?(app_uuid, embedded_type)
        ApplicationContainerProxy.rpc_exec('libra', @id) do |client|
          client.has_embedded_app(:uuid => app_uuid,
                                  :embedded_type => embedded_type) do |response|
            output = response[:body][:data][:output]
            return output == true
          end
        end
      end
      
      #
      # Returns whether this server has already reserved the specified uid as a uid or gid
      #
      def has_uid_or_gid?(uid)
        ApplicationContainerProxy.rpc_exec('libra', @id) do |client|
          client.has_uid_or_gid(:uid => uid.to_s) do |response|
            output = response[:body][:data][:output]
            return output == true
          end
        end
      end
      
      def run_cartridge_command(framework, app, gear, command, arg=nil, allow_move=true)
        arguments = "'#{gear.name}' '#{app.user.namespace}' '#{gear.uuid}'"
        arguments += " '#{arg}'" if arg

        if allow_move
          Nurture.application(app.user.login, app.user.uuid, app.name, app.user.namespace, framework, command, app.uuid)
          Apptegic.application(app.user.login, app.user.uuid, app.name, app.user.namespace, framework, command, app.uuid)
        end
        
        result = execute_direct(framework, command, arguments)
        begin
          resultIO = parse_result(result, app, command)
        rescue StickShift::InvalidNodeException => e
          if command != 'configure' && allow_move
            @id = e.server_identity
            Rails.logger.debug "DEBUG: Changing server identity of '#{gear.name}' from '#{gear.server_identity}' to '#{@id}'"
            dns_service = StickShift::DnsService.instance
            dns_service.deregister_application(app.name, app.user.namespace)
            dns_service.register_application(app.name, app.user.namespace, get_public_hostname)
            dns_service.publish
            gear.server_identity = @id
            app.save
            #retry
            result = execute_direct(framework, command, arguments)
            resultIO = parse_result(result, app, command)
          else
            raise
          end
        end
        if resultIO.exitcode != 0
          resultIO.debugIO << "Cartridge return code: " + resultIO.exitcode.to_s
          begin
            raise StickShift::NodeException.new("Node execution failure (invalid exit code from node).  If the problem persists please contact Red Hat support.", 143, resultIO)
          rescue StickShift::NodeException => e
            if command == 'deconfigure'
              if framework.start_with?('embedded/')
                if has_embedded_app?(app.uuid, framework[9..-1])
                  raise
                else
                  Rails.logger.debug "DEBUG: Component '#{framework}' in application '#{app.name}' not found on node '#{@id}'.  Continuing with deconfigure."
                end
              else
                if has_app?(app.uuid, app.name)
                  raise
                else
                  Rails.logger.debug "DEBUG: Application '#{app.name}' not found on node '#{@id}'.  Continuing with deconfigure."
                end
              end
            else
              raise
            end
          end
        end
        resultIO
      end
      
      def self.rpc_find_available(node_profile=nil, district_uuid=nil, forceRediscovery=false)
        current_server, current_capacity = nil, nil
        additional_filters = []
        district_uuid = nil if district_uuid == 'NONE'
        
        if node_profile
          additional_filters.push({:fact => "node_profile",
                                   :value => node_profile,
                                   :operator => "=="})
        end
        
        if district_uuid
          additional_filters.push({:fact => "district_uuid",
                                   :value => district_uuid,
                                   :operator => "=="})
          additional_filters.push({:fact => "district_active",
                                   :value => true.to_s,
                                   :operator => "=="})
        else
          additional_filters.push({:fact => "active_capacity",
                                   :value => '100',
                                   :operator => "<"})
          #TODO how do you filter on a fact not being set
          additional_filters.push({:fact => "district_uuid",
                                   :value => "NONE",
                                   :operator => "=="})

        end
    
        rpc_get_fact('active_capacity', nil, forceRediscovery, additional_filters) do |server, capacity|
          Rails.logger.debug "Next server: #{server} active capacity: #{capacity}"
          if !current_capacity || capacity.to_i < current_capacity.to_i
            current_server = server
            current_capacity = capacity
          end
          Rails.logger.debug "Current server: #{current_server} active capacity: #{current_capacity}"
        end
        return current_server, current_capacity
      end
      
      def self.rpc_find_one(node_profile=nil)
        current_server = nil
        additional_filters = []

        if node_profile
          additional_filters.push({:fact => "node_profile",
                                   :value => node_profile,
                                   :operator => "=="})
        end

        options = rpc_options
        options[:filter]['fact'] = options[:filter]['fact'] + additional_filters
        options[:mcollective_limit_targets] = "1"

        rpc_client = rpcclient('rpcutil', :options => options)
        begin
          rpc_client.get_fact(:fact => 'public_hostname') do |response|
            raise StickShift::NodeException.new("No nodes found.  If the problem persists please contact Red Hat support.", 140) unless Integer(response[:body][:statuscode]) == 0
            current_server = response[:senderid]
          end
        ensure
          rpc_client.disconnect
        end
        return current_server
      end
      
      def self.rpc_options
        # Make a deep copy of the default options
        Marshal::load(Marshal::dump(Rails.configuration.rpc_opts))
      end
    
      #
      # Return the value of the MCollective response
      # for both a single result and a multiple result
      # structure
      #
      def self.rvalue(response)
        result = nil
    
        if response[:body]
          result = response[:body][:data][:value]
        elsif response[:data]
          result = response[:data][:value]
        end
    
        result
      end
    
      def rsuccess(response)
        response[:body][:statuscode].to_i == 0
      end
    
      #
      # Returns the fact value from the specified server.
      # Yields to the supplied block if there is a non-nil
      # value for the fact.
      #
      def self.rpc_get_fact(fact, server=nil, forceRediscovery=false, additional_filters=nil)
        result = nil
        options = rpc_options
        options[:filter]['fact'] = options[:filter]['fact'] + additional_filters if additional_filters
    
        Rails.logger.debug("DEBUG: rpc_get_fact: fact=#{fact}")
        rpc_exec('rpcutil', server, forceRediscovery, options) do |client|
          client.get_fact(:fact => fact) do |response|
            next unless Integer(response[:body][:statuscode]) == 0
    
            # Yield the server and the value to the block
            result = rvalue(response)
            yield response[:senderid], result if result
          end
        end
    
        result
      end
    
      #
      # Given a known fact and node, get a single fact directly.
      # This is significantly faster then the get_facts method
      # If multiple nodes of the same name exist, it will pick just one
      #
      def rpc_get_fact_direct(fact)
          options = ApplicationContainerProxy.rpc_options
    
          rpc_client = rpcclient("rpcutil", :options => options)
          begin
            result = rpc_client.custom_request('get_fact', {:fact => fact}, @id, {'identity' => @id})[0]
            if (result && defined? result.results && result.results.has_key?(:data))
              value = result.results[:data][:value]
            else
              raise StickShift::NodeException.new("Node execution failure (error getting fact).  If the problem persists please contact Red Hat support.", 143)
            end
          ensure
            rpc_client.disconnect
          end
    
          return value
      end
    
      #
      # Execute direct rpc call directly against a node
      # If more then one node exists, just pick one
      def rpc_exec_direct(agent)
          options = ApplicationContainerProxy.rpc_options
          rpc_client = rpcclient(agent, :options => options)
          Rails.logger.debug("DEBUG: rpc_exec_direct: rpc_client=#{rpc_client}")
          rpc_client
      end

      def self.get_all_gears_impl
        gear_map = {}
        begin
          options = ApplicationContainerProxy.rpc_options
          rpc_client = rpcclient('libra', :options => options)
          mc_args = { :gear_map => {} }
          rpc_client.custom_request('get_all_gears', mc_args, nil).each { |response|
            if response.results[:statuscode] == 0
              sub_gear_map = response.results[:data][:output]
              sender = response.results[:sender]
              sub_gear_map.each { |k,v|
                gear_map[k] = "[#{sender}, uid:#{v}]"
              }
            end
          }
        ensure
          rpc_client.disconnect
        end
        gear_map
      end

      def self.execute_parallel_jobs_impl(handle)
        begin
          options = ApplicationContainerProxy.rpc_options
          rpc_client = rpcclient('libra', :options => options)
          mc_args = handle.clone
          rpc_client.custom_request('execute_parallel', mc_args, nil, {'identity' => handle.keys}).each { |mcoll_reply|
            if mcoll_reply.results[:statuscode] == 0              
              output = mcoll_reply.results[:data][:output]
              exitcode = mcoll_reply.results[:data][:exitcode]
              sender = mcoll_reply.results[:sender]
              Rails.logger.debug("DEBUG: Output of parallel execute: #{output}, exitcode: #{exitcode}, from: #{sender}")
              handle[sender] = output if exitcode == 0
            end
          }
        ensure
          rpc_client.disconnect
        end
      end
    end
  end
end
