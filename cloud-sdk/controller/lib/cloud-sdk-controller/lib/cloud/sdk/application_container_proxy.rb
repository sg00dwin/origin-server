require 'open4'
require 'pp'

module Cloud
  module Sdk
    class ApplicationContainerProxy
      @proxy_provider = Cloud::Sdk::ApplicationContainerProxy
      
      def self.provider=(provider_class)
        @proxy_provider = provider_class
      end
      
      def self.instance(id)
        @proxy_provider.new(id)
      end
      
      def self.find_available(node_profile=nil)
        @proxy_provider.find_available_impl(node_profile)
      end
      
      def self.find_one(node_profile=nil)
        @proxy_provider.find_one_impl(node_profile)
      end
      
      def self.blacklisted?(name)
      end
      
      attr_accessor :id
      def self.find_available_impl(node_profile=nil)
        @proxy_provider.instance('localhost')
      end
      
      def self.find_one_impl(node_profile=nil)
        @proxy_provider.instance('localhost')
      end
      
      def initialize(id)
        @id = id
      end
      
      def reserve_uid
        reserved_uid = nil
        reserved_uid
      end
      
      def get_available_cartridges
        reply = exec_command('cdk-cartridge-list', '--porcelain --with-descriptors')
        result = parse_result(reply)
        cart_data = JSON.parse(result.resultIO.string)
        cart_data.map! {|c| Cloud::Sdk::Cartridge.new.from_descriptor(YAML.load(c))}
      end
      
      def create(app, gear)
        result = nil
        cmd = "cdk-app-create"
        args = "--with-app-uuid '#{app.uuid}' --named '#{app.name}' --with-container-uuid '#{gear.uuid}'"
        Rails.logger.debug("App creation command: #{cmd} #{args}")
        reply = exec_command(cmd, args)
        result = parse_result(reply)
        result
      end
    
      def destroy(app, gear)
      end
      
      def add_authorized_ssh_key(app, gear, ssh_key, key_type=nil, comment=nil)
        cmd = "cdk-authorized-ssh-key-add"
        args = "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -s '#{ssh_key}'"
        args += " -t '#{key_type}'" if key_type
        args += " -m '-#{comment}'" if comment
        Rails.logger.debug("App ssh key: #{cmd} #{args}")
        result = exec_command(cmd, args)
        parse_result(result)
      end
      
      def remove_authorized_ssh_key(app, gear, ssh_key)
        cmd = "cdk-authorized-ssh-key-remove"
        args = "--with-app-uuid '#{app.uuid}' --with-container-uuid '#{gear.uuid}' -s '#{ssh_key}'" 
        Rails.logger.debug("Remove ssh key: #{cmd} #{args}")
        result = exec_command(cmd, args)
        parse_result(result)
      end
    
      def add_env_var(app, key, value)
      end
      
      def remove_env_var(app, key)
      end
    
      def add_broker_auth_key(app, id, token)
      end
    
      def remove_broker_auth_key(app)
      end
      
      def preconfigure_cartridge(app, gear, cart)
        Rails.logger.debug("Inside preconfigure_cartridge :: application: #{app.name} :: cartridge name: #{cart}")
        return ResultIO.new
      end
      
      def configure_cartridge(app, gear, cart)
        Rails.logger.debug("Inside configure_cartridge :: application: #{app.name} :: cartridge name: #{cart}")
        return ResultIO.new
      end
      
      def deconfigure_cartridge(app, gear, cart)
        Rails.logger.debug("Inside deconfigure_cartridge :: application: #{app.name} :: cartridge name: #{cart}")
        return ResultIO.new
      end
      
      def get_public_hostname
      end
      
      def start(app, cart)
      end
      
      def stop(app, cart)
      end
      
      def force_stop(app, cart)
      end
 
      def expose_port(app, cart)
      end
 
      def conceal_port(app, cart)
      end
      
      def show_port(app, cart)
      end
      
      def restart(app, cart)
      end
      
      def reload(app, cart)
      end
      
      def status(app, cart)
      end
      
      def tidy(app, cart)
      end
      
      def threaddump(app, cart)
      end
      
      def system_messages(app, cart)
      end
      
      def add_alias(app, cart, server_alias)
      end
      
      def remove_alias(app, cart, server_alias)
      end
      
      def add_component(app, component)
      end
      
      def remove_component(app, component)
      end
      
      def start_component(app, component)
      end
      
      def stop_component(app, component)
      end
      
      def restart_component(app, component)
      end
      
      def reload_component(app, component)
      end
      
      def component_status(app, component)
      end
      
      def move_app(app, destination_container_proxy, node_profile=nil)
      end
      
      def update_namespace(app, cart, new_ns, old_ns)
      end

      def exec_command(cmd, args)
        reply = {}
        exitcode = 1
        pid, stdin, stdout, stderr = nil, nil, nil, nil
        Bundler.with_clean_env {
          pid, stdin, stdout, stderr = Open4::popen4("#{cmd} #{args} 2>&1")
          stdin.close
          ignored, status = Process::waitpid2 pid
          exitcode = status.exitstatus
        }
        # Do this to avoid cartridges that might hold open stdout
        output = ""
        begin
          Timeout::timeout(5) do
            while (line = stdout.gets)
              output << line
            end
          end
        rescue Timeout::Error
          Rails.logger.debug("exec_command WARNING - stdout read timed out")
        end

#        if exitcode == 0
#          Rails.logger.debug("exec_command (#{exitcode})\n------\n#{output}\n------)")
#        else
#          Rails.logger.debug("exec_command ERROR (#{exitcode})\n------\n#{output}\n------)")
#        end

        reply[:output] = output
        reply[:exitcode] = exitcode
        Rails.logger.error("exec_command failed #{exitcode}.  Output #{output}") unless exitcode == 0
        reply
      end

      def parse_result(cmd_result, app=nil, command=nil)
        result = ResultIO.new
        
        Rails.logger.debug("cmd_reply:  #{cmd_result}")
        output = nil
        if (cmd_result && cmd_result.has_key?(:output))
          output = cmd_result[:output]
          result.exitcode = cmd_result[:exitcode]
        else
          raise Cloud::Sdk::NodeException.new("Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", 143)
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
    end
  end
end
