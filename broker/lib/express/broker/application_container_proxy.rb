require 'mcollective'
require 'openshift'
require 'express/broker/nurture'
require 'express/broker/apptegic'

include MCollective::RPC
module Express
  module Broker
    class ApplicationContainerProxy
      @@C_CONTROLLER = 'cloud-sdk-node'
      attr_accessor :id, :current_capacity, :district
      
      def initialize(id, current_capacity=nil, district=nil)
        @id = id
        @current_capacity = current_capacity
        @district = district
      end
      
      def self.find_available_impl(node_profile=nil, district_uuid=nil)
        if Rails.configuration.districts[:enabled] && (!district_uuid || district_uuid == 'NONE')  
          district = District.find_available()
          if district
            district_uuid = district.uuid
            Rails.logger.debug "DEBUG: find_available_impl: district_uuid: #{district_uuid}"
          elsif Rails.configuration.districts[:require_for_app_create]
            raise Cloud::Sdk::NodeException.new("No district nodes available.  If the problem persists please contact Red Hat support.", 140)
          end
        end
        current_server, current_capacity = rpc_find_available(node_profile, district_uuid)
        Rails.logger.debug "CURRENT SERVER: #{current_server}"
        if !current_server
          current_server, current_capacity = rpc_find_available(node_profile, district_uuid, true)
          Rails.logger.debug "CURRENT SERVER: #{current_server}"
        end
        raise Cloud::Sdk::NodeException.new("No nodes available.  If the problem persists please contact Red Hat support.", 140) unless current_server
        Rails.logger.debug "DEBUG: find_available_impl: current_server: #{current_server}: #{current_capacity}"

        ApplicationContainerProxy.new(current_server, current_capacity, district)
      end

      def self.blacklisted?(name)
        OpenShift::Blacklist.in_blacklist?(name)
      end
      
      IGNORE_CARTS = %w(abstract abstract-httpd embedded)
      def get_available_cartridges(cart_type)
        cartridges = []
        
        case cart_type
        when 'standalone'
          ApplicationContainerProxy.rpc_get_fact('cart_list', @id) do |server, carts|
            cartridges = carts.split('|')
          end
        when 'embedded'
          ApplicationContainerProxy.rpc_get_fact('embed_cart_list', @id) do |server, embedcarts|
            cartridges = embedcarts.split('|')
          end
        end
        cartridges.delete_if {|cart| IGNORE_CARTS.include?(cart)}
        
        cartridges
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
            reserved_uid = Cloud::Sdk::DataStore.instance.reserve_district_uid(district_uuid)
            raise Cloud::Sdk::CdkException.new("uid could not be reserved") unless reserved_uid
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
            Cloud::Sdk::DataStore.instance.unreserve_district_uid(district_uuid, uid)
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
            Cloud::Sdk::DataStore.instance.inc_district_externally_reserved_uids_size(district_uuid)
          end
        end
      end
      

      def create(app)
        result = nil
        (1..10).each do |i|
          mcoll_reply = execute_direct(@@C_CONTROLLER, 'configure', "-c '#{app.uuid}' -i '#{app.uid}'")
          result = parse_result(mcoll_reply)
          if result.exitcode == 129 && has_uid_or_gid?(app.uid) # Code to indicate uid already taken
            destroy(app, true)
            inc_externally_reserved_uids_size
            app.uid = reserve_uid
            app.save
          else
            break
          end
        end
        result
      end
    
      def destroy(app, keep_uid=false, uid=nil)
        result = execute_direct(@@C_CONTROLLER, 'deconfigure', "-c '#{app.uuid}'")
        result_io = parse_result(result)
        
        uid = app.uid unless uid
        
        unless keep_uid
          unreserve_uid(uid)
        end
        return result_io
      end

      def add_authorized_ssh_key(app, ssh_key, key_type=nil, message=nil)
        cmd = "-c '#{app.uuid}' -s '#{ssh_key}'"
        cmd += " -t '#{key_type}'" if key_type
        cmd += " -m '-#{message}'" if message
        result = execute_direct(@@C_CONTROLLER, 'add-authorized-ssh-key', cmd)
        parse_result(result)
      end

      def remove_authorized_ssh_key(app, ssh_key)
        result = execute_direct(@@C_CONTROLLER, 'remove-authorized-ssh-key', "-c '#{app.uuid}' -s '#{ssh_key}'")
        parse_result(result)
      end

      def add_env_var(app, key, value)
        result = execute_direct(@@C_CONTROLLER, 'add-env-var', "-c '#{app.uuid}' -k '#{key}' -v '#{value}'")
        parse_result(result)
      end
      
      def remove_env_var(app, key)
        result = execute_direct(@@C_CONTROLLER, 'remove-env-var', "-c '#{app.uuid}' -k '#{key}'")
        parse_result(result)
      end
    
      def add_broker_auth_key(app, iv, token)
        result = execute_direct(@@C_CONTROLLER, 'add-broker-auth-key', "-c '#{app.uuid}' -i '#{iv}' -t '#{token}'")
        parse_result(result)
      end
    
      def remove_broker_auth_key(app)
        result = execute_direct(@@C_CONTROLLER, 'remove-broker-auth-key', "-c '#{app.uuid}'")
        handle_controller_result(result)
      end
      
      def preconfigure_cartridge(app, cart)
        run_cartridge_command(cart, app, "preconfigure")
      end
      
      def configure_cartridge(app, cart)
        run_cartridge_command(cart, app, "configure")
      end
      
      def deconfigure_cartridge(app, cart)
        run_cartridge_command(cart, app, "deconfigure")
      end
      
      def get_public_hostname
        rpc_get_fact_direct('public_hostname')
      end
      
      def get_capacity
        rpc_get_fact_direct('capacity').to_i
      end
      
      def get_district_uuid
        rpc_get_fact_direct('district')
      end
      
      def get_ip_address
        rpc_get_fact_direct('ipaddress')
      end
      
      def start(app, cart)
        run_cartridge_command(cart, app, "start")
      end
      
      def stop(app, cart)
        run_cartridge_command(cart, app, "stop")
      end
      
      def force_stop(app, cart)
        run_cartridge_command(cart, app, "force-stop")
      end
      
      def restart(app, cart)
        run_cartridge_command(cart, app, "restart")
      end
      
      def reload(app, cart)
        run_cartridge_command(cart, app, "reload")
      end
      
      def status(app, cart)
        run_cartridge_command(cart, app, "status")
      end
      
      def tidy(app, cart)
        run_cartridge_command(cart, app, "tidy")
      end
      
      def threaddump(app, cart)
        run_cartridge_command(cart, app, "threaddump")
      end
      
      def add_alias(app, cart, server_alias)
        run_cartridge_command(cart, app, "add-alias", server_alias)
      end
      
      def remove_alias(app, cart, server_alias)
        run_cartridge_command(cart, app, "remove-alias", server_alias)
      end
      
      def add_component(app, component)
        reply = ResultIO.new
        begin
          reply.append run_cartridge_command('embedded/' + component, app, 'configure')
        rescue Exception => e
          begin
            Rails.logger.debug "DEBUG: Failed to embed '#{component}' in '#{app.name}' for user '#{app.user.login}'"
            reply.debugIO << "Failed to embed '#{component} in '#{app.name}'"
            reply.append run_cartridge_command('embedded/' + component, app, 'deconfigure')
          ensure
            raise
          end
        end
        
        component_details = reply.appInfoIO.string.empty? ? '' : reply.appInfoIO.string
        reply.debugIO << "Embedded app details: #{component_details}"
        [reply, component_details]
      end
      
      def remove_component(app, component)
        Rails.logger.debug "DEBUG: Deconfiguring embedded application '#{component}' in application '#{app.name}' on node '#{@id}'"
        return run_cartridge_command('embedded/' + component, app, 'deconfigure')
      end
      
      def start_component(app, component)
        run_cartridge_command('embedded/' + component, app, "start")
      end
      
      def stop_component(app, component)
        run_cartridge_command('embedded/' + component, app, "stop")
      end
      
      def restart_component(app, component)
        run_cartridge_command('embedded/' + component, app, "restart")    
      end
      
      def reload_component(app, component)
        run_cartridge_command('embedded/' + component, app, "reload")    
      end
      
      def component_status(app, component)
        run_cartridge_command('embedded/' + component, app, "status")    
      end
      
      def move_app(app, destination_container, destination_district_uuid=nil, allow_change_district=false, node_profile=nil)
        source_container = app.container

        #unless app.embedded.nil?
          #raise Cloud::Sdk::UserException.new("Cannot move app '#{app.name}' with mysql embedded",1) if app.embedded.has_key?('mysql-5.1')
          #raise Cloud::Sdk::UserException.new("Cannot move app '#{app.name}' with mongo embedded",1) if app.embedded.has_key?('mongodb-2.0')
          #raise Cloud::Sdk::UserException.new("Cannot move app '#{app.name}' with postgresql embedded",1) if app.embedded.has_key?('postgresql-8.4')
        #end

        if node_profile
          app.node_profile = node_profile
        end

        source_district_uuid = source_container.get_district_uuid
        if destination_container.nil?
          unless allow_change_district
            if destination_district_uuid && destination_district_uuid != source_district_uuid
              raise Cloud::Sdk::UserException.new("Error moving app.  Cannot change district from '#{source_district_uuid}' to '#{destination_district_uuid}'.", 1)
            else
              destination_district_uuid = source_district_uuid
            end
          end
          destination_container = ApplicationContainerProxy.find_available_impl(app.node_profile, destination_district_uuid)
          destination_district_uuid = destination_container.get_district_uuid if allow_change_district
        else
          if destination_district_uuid
            log_debug "DEBUG: Destination district uuid '#{destination_district_uuid}' is being ignored in favor of destination container #{destination_container.id}"
          end
          destination_district_uuid = destination_container.get_district_uuid
          unless allow_change_district || (source_district_uuid == destination_district_uuid)
            raise Cloud::Sdk::UserException.new("Resulting move would change districts from '#{source_district_uuid}' to '#{destination_district_uuid}'", 1)
          end
        end
        
        keep_uid = destination_district_uuid == source_district_uuid

        if source_container.id == destination_container.id
          raise Cloud::Sdk::UserException.new("Error moving app.  Old and new servers are the same: #{source_container.id}", 1)
        end
        
        orig_uid = app.uid

        log_debug "DEBUG: Moving app '#{app.name}' with uuid #{app.uuid} from #{source_container.id} to #{destination_container.id}"

        num_tries = 2
        reply = ResultIO.new
        begin
          log_debug "DEBUG: Stopping existing app '#{app.name}' before moving"
          (1..num_tries).each do |i|
            begin
              reply.append source_container.stop(app, app.framework)
              break
            rescue Exception => e
              log_debug "DEBUG: Error stopping existing app on try #{i}: #{e.message}"
              raise if i == num_tries
            end
          end
          
          begin
            unless app.embedded.nil?
              app.embedded.each do |cart, cart_info|
                log_debug "DEBUG: Performing cartridge level pre-move for embedded #{cart} for '#{app.name}' on #{source_container.id}"
                reply.append source_container.send(:run_cartridge_command, "embedded/" + cart, app, "pre-move", nil, false)
              end
            end

            begin
              unless keep_uid
                app.uid = destination_container.reserve_uid(destination_district_uuid)
              end
              log_debug "DEBUG: Creating new account for app '#{app.name}' on #{destination_container.id}"
              reply.append destination_container.create(app)
  
              log_debug "DEBUG: Moving content for app '#{app.name}' to #{destination_container.id}"
              log_debug `eval \`ssh-agent\`; ssh-add /var/www/libra/broker/config/keys/rsync_id_rsa; ssh -o StrictHostKeyChecking=no -A root@#{source_container.get_ip_address} "rsync -a -e 'ssh -o StrictHostKeyChecking=no' /var/lib/libra/#{app.uuid}/ root@#{destination_container.get_ip_address}:/var/lib/libra/#{app.uuid}/"`
              if $?.exitstatus != 0
                raise Cloud::Sdk::NodeException.new("Error moving app '#{app.name}' from #{source_container.id} to #{destination_container.id}", 143)
              end
  
              begin
                log_debug "DEBUG: Performing cartridge level move for '#{app.name}' on #{destination_container.id}"
                reply.append destination_container.send(:run_cartridge_command, app.framework, app, "move", nil, false)
                unless app.embedded.nil?
                  app.embedded.each do |cart, cart_info|
                    log_debug "DEBUG: Performing cartridge level move for embedded #{cart} for '#{app.name}' on #{destination_container.id}"
                    embedded_reply = destination_container.send(:run_cartridge_command, "embedded/" + cart, app, "move", nil, false)
                    component_details = embedded_reply.appInfoIO.string
                    unless component_details.empty?
                      app.embedded[cart] = { "info" => component_details }
                    end
                    reply.append embedded_reply
                    log_debug "DEBUG: Performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{destination_container.id}"
                    reply.append destination_container.send(:run_cartridge_command, "embedded/" + cart, app, "post-move", nil, false)
                  end
                end

                unless app.aliases.nil?
                  app.aliases.each do |server_alias|
                    destination_container.add_alias(app, app.framework, server_alias)
                  end
                end
              rescue Exception => e
                reply.append destination_container.send(:run_cartridge_command, app.framework, app, "remove-httpd-proxy", nil, false)          
                raise
              end
  
              log_debug "DEBUG: Starting '#{app.name}' after move on #{destination_container.id}"
              (1..num_tries).each do |i|
                begin
                  reply.append destination_container.start(app, app.framework)
                  break
                rescue Exception => e
                  log_debug "DEBUG: Error starting after move on try #{i}: #{e.message}"
                  raise if i == num_tries
                end
              end
  
              log_debug "DEBUG: Fixing DNS and s3 for app '#{app.name}' after move"
              log_debug "DEBUG: Changing server identity of '#{app.name}' from '#{source_container.id}' to '#{destination_container.id}'"
              app.server_identity = destination_container.id
              app.container = destination_container
              reply.append app.recreate_dns
              app.save
            rescue Exception => e
              reply.append destination_container.destroy(app, keep_uid)
              raise
            end
          rescue Exception => e
            app.embedded.each do |cart, cart_info|
              begin
                log_debug "DEBUG: Performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{source_container.id}"
                reply.append source_container.send(:run_cartridge_command, "embedded/" + cart, app, "post-move", nil, false)
              rescue Exception => e
                log_error "ERROR: Error performing cartridge level post-move for embedded #{cart} for '#{app.name}' on #{source_container.id}: #{e.message}"
              end
            end
            raise
          end
        rescue Exception => e
          reply.append source_container.run_cartridge_command(app.framework, app, "start", nil, false)
          raise
        ensure
          log_debug "URL: http://#{app.name}-#{app.user.namespace}.#{Rails.configuration.cdk[:domain_suffix]}"
        end

        log_debug "DEBUG: Deconfiguring old app '#{app.name}' on #{source_container.id} after move"
        (1..num_tries).each do |i|
          begin
            reply.append source_container.run_cartridge_command(app.framework, app, "deconfigure", nil, false)
            reply.append source_container.destroy(app, keep_uid, orig_uid)
            break
          rescue Exception => e
            log_debug "DEBUG: Error deconfiguring old app on try #{i}: #{e.message}"
            raise if i == num_tries
          end
        end
        log_debug "Successfully moved '#{app.name}' with uuid #{app.uuid} from #{source_container.id} to #{destination_container.id}"
        reply
      end
      
      def update_namespace(app, cart, new_ns, old_ns)
        mcoll_reply = execute_direct(cart, 'update-namespace', "#{app.name} #{new_ns} #{old_ns} #{app.uuid}")
        parse_result(mcoll_reply)
      end
      
      #
      # Execute an RPC call for the specified agent.
      # If a server is supplied, only execute for that server.
      #
      def self.rpc_exec(agent, server=nil, forceRediscovery=false, options = rpc_options)
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
      
        result
      end
      
      def set_district(uuid, active)
        mc_args = { :uuid => uuid,
                    :active => active}
        rpc_client = rpc_exec_direct('libra')
        result = nil
        begin
          Rails.logger.debug "DEBUG: rpc_client.custom_request('set_district', #{mc_args.inspect}, #{@id}, {'identity' => #{@id}})"
          result = rpc_client.custom_request('set_district', mc_args, @id, {'identity' => @id})
          Rails.logger.debug "DEBUG: #{result.inspect}"
        ensure
          rpc_client.disconnect
        end
        Rails.logger.debug result.inspect
        result
      end
      
      protected
      
      def log_debug(message)
        Rails.logger.debug message
        puts message
      end
      
      def log_error(message)
        Rails.logger.error message
        puts message
      end
      
      def execute_direct(cartridge, action, args)
          mc_args = { :cartridge => cartridge,
                      :action => action,
                      :args => args }
          rpc_client = rpc_exec_direct('libra')
          result = nil
          begin
            Rails.logger.debug "DEBUG: rpc_client.custom_request('cartridge_do', #{mc_args.inspect}, #{@id}, {'identity' => #{@id}})"
            result = rpc_client.custom_request('cartridge_do', mc_args, @id, {'identity' => @id})
            Rails.logger.debug "DEBUG: #{result.inspect}"
          ensure
            rpc_client.disconnect
          end
          Rails.logger.debug result.inspect
          result
      end
      
      def parse_result(mcoll_reply, app=nil, command=nil)
        result = ResultIO.new
        
        mcoll_result = mcoll_reply[0]
        output = nil
        if (mcoll_result && defined? mcoll_result.results && mcoll_result.results.has_key?(:data))
          output = mcoll_result.results[:data][:output]
          result.exitcode = mcoll_result.results[:data][:exitcode]
          if command == "status" && app
            if result.exitcode == 0
              result.resultIO << output
            else
              result.exitcode = 0
              result.resultIO << "Application '#{app.name}' is either stopped or inaccessible"
            end
          else
            #Rails.logger.debug "--output--\n\n#{output}\n\n"
          end
        else
          server_identity = app ? ApplicationContainerProxy.find_app(app.uuid, app.name) : nil
          if server_identity && @id != server_identity
            raise Cloud::Sdk::InvalidNodeException.new("Node execution failure (invalid  node).  If the problem persists please contact Red Hat support.", 143, nil, server_identity)
          else
            raise Cloud::Sdk::NodeException.new("Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", 143)
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
              else
                result.debugIO << line
              end
            else # exitcode != 0
              #result.debugIO << line
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
      
      def run_cartridge_command(framework, app, command, arg=nil, allow_move=true)
        arguments = "'#{app.name}' '#{app.user.namespace}' '#{app.uuid}'"
        arguments += " '#{arg}'" if arg
          
        if allow_move
          Nurture.application(app.user.login, app.user.uuid, app.name, app.user.namespace, framework, command, app.uuid)
          Apptegic.application(app.user.login, app.user.uuid, app.name, app.user.namespace, framework, command, app.uuid)
        end
        
        result = execute_direct(framework, command, arguments)
        begin
          resultIO = parse_result(result, app, command)
        rescue Cloud::Sdk::InvalidNodeException => e
          if command != 'configure' && allow_move
            @id = e.server_identity
            Rails.logger.debug "DEBUG: Changing server identity of '#{app.name}' from '#{app.server_identity}' to '#{@id}'"
            dns_service = Cloud::Sdk::DnsService.instance
            dns_service.deregister_application(app.name, app.user.namespace)
            dns_service.register_application(app.name, app.user.namespace, get_public_hostname)
            dns_service.publish
            app.server_identity = @id
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
            raise Cloud::Sdk::NodeException.new("Node execution failure (invalid exit code from node).  If the problem persists please contact Red Hat support.", 143, resultIO)
          rescue Cloud::Sdk::NodeException => e
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
          additional_filters.push({:fact => "capacity",
                                   :value => '100',
                                   :operator => "<"})
          #TODO how do you filter on a fact not being set
          additional_filters.push({:fact => "district_uuid",
                                   :value => "NONE",
                                   :operator => "=="})
        end
    
        rpc_get_fact('capacity', nil, forceRediscovery, additional_filters) do |server, capacity|
          Rails.logger.debug "Next server: #{server} capacity: #{capacity}"
          if !current_capacity || capacity.to_i < current_capacity.to_i
            current_server = server
            current_capacity = capacity
          end
          Rails.logger.debug "Current server: #{current_server} capacity: #{current_capacity}"
        end
        return current_server, current_capacity
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
              raise Cloud::Sdk::NodeException.new("Node execution failure (error getting fact).  If the problem persists please contact Red Hat support.", 143)
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
    end
  end
end
