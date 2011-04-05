require 'libra/helper'
require 'aws'
require 'json'
require 'resolv'

module Libra
  class Server
    # Cartridge definitions
    @@C_CONTROLLER = 'li-controller-0.1'

    attr_reader :name, :repos

    def initialize(name, repos=nil)
      @name = name
      @repos = repos.to_i if repos
    end

    def self.create(opts={})
      # Set defaults
      opts[:aws_name] ||= Libra.c[:aws_name]
      opts[:key_name] ||= Libra.c[:aws_keypair]
      opts[:image_id] ||= Libra.c[:aws_ami]
      opts[:max_count] ||= 1
      opts[:instance_type] ||= "m1.large"

      # Create the instances in EC2, returning
      # an array of the image id's
      instances = Helper.ec2.launch_instances(opts[:image_id],
                      :max_count => opts[:max_count],
                      :key_name => opts[:key_name],
                      :instance_type => opts[:instance_type]).collect do |server|
        server[:aws_instance_id]
      end

      # Tag the instance(s) if necessary
      if opts[:aws_name]
        instances.each {|i| Helper.ec2.create_tag(i, 'Name', opts[:aws_name])}
      end

      instances
    end

    #
    # Returns the preferred available server.
    # Currently this is defined by the server that
    # has the least number of git repos on it.
    #
    def self.find_available
      # Defaults
      current_server, current_repos = rpc_find_available
      if !current_server
        current_server, current_repos = rpc_find_available(true)
      end
      raise NodeException.new(140), "No nodes available.  If the problem persists please contact Red Hat support.", caller[0..5] unless current_server
      Libra.logger_debug "DEBUG: server.rb:find_available #{current_server}: #{current_repos}" if Libra.c[:rpc_opts][:verbose]
      new(current_server, current_repos)
    end
    
    def self.rpc_find_available(forceRediscovery=false)
      current_server, current_repos = nil, 100000000
      Helper.rpc_get_fact('git_repos', nil, forceRediscovery) do |server, repos|
        num_repos = repos.to_i
        if num_repos < current_repos
          current_server = server
          current_repos = num_repos
        end
      end
      return current_server, current_repos
    end

    #
    # Returns a list of all the servers that respond
    #
    def self.find_all
      servers = []

      Helper.rpc_get_fact('git_repos') do |server, repos|
        servers << new(server, repos)
      end

      servers
    end

    #
    # Add a DNS entry for new app
    #
    def self.nsupdate_add(application, namespace, public_ip, sshfp)
      host = "#{application}-#{namespace}"
      nsupdate_input_template = <<EOF
"server #{Libra.c[:resolver]}
zone #{Libra.c[:libra_domain]}
update delete #{host}.#{Libra.c[:libra_domain]}
update add #{host}.#{Libra.c[:libra_domain]} 60 A #{public_ip}
update add #{host}.#{Libra.c[:libra_domain]} 60 SSHFP 1 1 #{sshfp}
send"
EOF

      execute_nsupdate(nsupdate_input_template)
    end

    #
    # Remove a DNS entry for a deleted app
    #
    def self.nsupdate_del(application, namespace, public_ip)
      host = "#{application}-#{namespace}"
      nsupdate_input_template = <<EOF
"server #{Libra.c[:resolver]}
zone #{Libra.c[:libra_domain]}
update delete #{host}.#{Libra.c[:libra_domain]}
send"
EOF

      execute_nsupdate(nsupdate_input_template)
    end

    #
    # Add a DNS txt entry for new namespace
    #
    def self.nsupdate_add_txt(namespace)
      nsupdate_input_template = <<EOF
"server #{Libra.c[:resolver]}
zone #{Libra.c[:libra_domain]}
update delete #{namespace}.#{Libra.c[:libra_domain]}
update add #{namespace}.#{Libra.c[:libra_domain]} 60 TXT 'Text record for #{namespace}'
send"
EOF
      execute_nsupdate(nsupdate_input_template)
    end
    
    #
    # Remove a DNS txt entry for new namespace
    #
    def self.nsupdate_delete_txt(namespace)
      nsupdate_input_template = <<EOF
"server #{Libra.c[:resolver]}
zone #{Libra.c[:libra_domain]}
update delete #{namespace}.#{Libra.c[:libra_domain]} TXT
send"
EOF
      execute_nsupdate(nsupdate_input_template)
    end    

    def self.execute_nsupdate(nsupdate_input_template)
      nsupdate_string = eval nsupdate_input_template
      Libra.logger_debug "DEBUG: server.rb:self.execute_nsupdate nsupdate_input_template: #{nsupdate_input_template}" if Libra.c[:rpc_opts][:verbose]

      IO.popen("/usr/bin/nsupdate -L0 -v -y '#{Libra.c[:secret]}'", 'w'){ |io| io.puts nsupdate_string }
    end

    #
    # Get a DNS txt entry
    #
    def self.has_dns_txt?(namespace)
      dns = Resolv::DNS.new
      resp = dns.getresources("#{namespace}.#{Libra.c[:libra_domain]}", Resolv::DNS::Resource::IN::TXT)
      return resp.length > 0
    end
    
    def self.dyn_login
      # Set your customer name, username, and password on the command line 
      cn = 'demo-redhat'
      un = 'dmcphers'
      pw = 'Ond7Hekd75D'
      # Set up our HTTP object with the required host and path 
      url = URI.parse('https://api2.dynect.net/REST/Session/') 
      headers = { "Content-Type" => 'application/json' } 
      http = Net::HTTP.new(url.host, url.port) 
      http.set_debug_output $stderr 
      http.use_ssl = true 
      # Login and get an authentication token that will be used for all subsequent requests. 
      session_data = { :customer_name => cn, :user_name => un, :password => pw }
      auth_token = nil
      begin
        resp, data = http.post(url.path, JSON.generate(session_data), headers) 
        Libra.logger_debug "POST Session Response: #{data}" 
        result = JSON.parse(data) 
        auth_token = result['data']['token']
      rescue Exception => e
        raise_dns_exception(e)
      end
      # Is the session still alive? 
      #headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token } 
      #resp, data = http.get(url.path, headers) 
      #Libra.logger_debug 'GET Session Response: ', data, '\n'      
      return auth_token
    end
    
    def self.raise_dns_exception(e)
      Libra.logger_debug "DEBUG: Exception caught from DNS request: #{e.message}"
      raise DNSException.new(145), "Error communicating with DNS system.  If the problem persists please contact Red Hat support.", caller[0..5]
    end
    
    def self.dyn_logout(auth_token)
      # Logout
      resp, data = dyn_delete("Session/", auth_token)            
    end
    
    def self.dyn_create_a_record(application, namespace, public_ip, sshfp, auth_token)
      fqdn = "#{application}-#{namespace}.#{Libra.c[:libra_domain]}"
      # Create the A record
      path = "ARecord/#{Libra.c[:libra_domain]}/#{fqdn}/"
      record_data = { :rdata => { :address => public_ip }, :ttl => "60" }
      resp, data = dyn_post(path, record_data, auth_token)
    end
    
    def self.dyn_delete_a_record(application, namespace, auth_token)
      fqdn = "#{application}-#{namespace}.#{Libra.c[:libra_domain]}"
      # Create the A record
      path = "ARecord/#{Libra.c[:libra_domain]}/#{fqdn}/"
      resp, data = dyn_delete(path, auth_token)
    end
    
    def self.dyn_create_txt_record(namespace, auth_token)
      fqdn = "#{namespace}.#{Libra.c[:libra_domain]}"
      # Create the TXT record
      path = "TXTRecord/#{Libra.c[:libra_domain]}/#{fqdn}/" 
      record_data = { :rdata => { :txtdata => "Text record for #{namespace}"}, :ttl => "60" }
      resp, data = dyn_post(path, record_data, auth_token)
    end
    
    def self.dyn_delete_txt_record(namespace, auth_token)
      fqdn = "#{namespace}.#{Libra.c[:libra_domain]}"
      # Delete the TXT record
      path = "TXTRecord/#{Libra.c[:libra_domain]}/#{fqdn}/" 
      resp, data = dyn_delete(path, auth_token)
    end

    def self.dyn_publish(auth_token)
      # Publish the changes
      path = "Zone/#{Libra.c[:libra_domain]}/"
      publish_data = { "publish" => "true" }
      resp, data = dyn_put(path, publish_data, auth_token)
    end    
    
    def self.dyn_has_txt_record?(namespace, auth_token)
      fqdn = "#{namespace}.#{Libra.c[:libra_domain]}"
      path = "TXTRecord/#{Libra.c[:libra_domain]}/#{fqdn}/"
      return dyn_has?(path, auth_token)
    end
    
    def self.dyn_has_a_record?(application, namespace, auth_token)
      fqdn = "#{application}-#{namespace}.#{Libra.c[:libra_domain]}"
      path = "ARecord/#{Libra.c[:libra_domain]}/#{fqdn}/"
      return dyn_has?(path, auth_token)
    end
    
    def self.dyn_has?(path, auth_token)
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      url = URI.parse("https://api2.dynect.net/REST/#{path}")
      http = Net::HTTP.new(url.host, url.port) 
      http.set_debug_output $stderr 
      http.use_ssl = true
      has = false
      begin
        resp, data = http.get(url.path, headers)
        Libra.client_debug "DEBUG: DYNECT GET Response: #{data}"      
        if data
          data = JSON.parse(data)
          if data && data['status'] && data['status'] == 'failure'
            Libra.logger_debug "DEBUG: DYNECT GET Response status: #{data['status']}"
          elsif data && data['status'] == 'success'
            Libra.logger_debug "DEBUG: DYNECT GET Response data: #{data['data']}"
            #has = data['data'][0].length > 0
            has = true
          end
        end
      rescue Exception => e        
        raise_dns_exception(e)
      end
      return has
    end
    
    def self.dyn_put(path, put_data, auth_token)
      return dyn_put_post(path, put_data, auth_token, true)
    end
    
    def self.dyn_post(path, post_data, auth_token)
      return dyn_put_post(path, post_data, auth_token)
    end
    
    def self.dyn_put_post(path, post_data, auth_token, put=false)
      url = URI.parse("https://api2.dynect.net/REST/#{path}")
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      resp, data = nil, nil      
      http = Net::HTTP.new(url.host, url.port) 
      http.set_debug_output $stderr 
      http.use_ssl = true
      json_data = JSON.generate(post_data);
      begin
        if put
          resp, data = http.put(url.path, json_data, headers)
        else
          resp, data = http.post(url.path, json_data, headers)
        end
        Libra.logger_debug "DEBUG: DYNECT PUT/POST Response: #{data}"
      rescue Exception => e        
        raise_dns_exception(e)
      end
      return resp, data
    end
    
    def self.dyn_delete(path, auth_token)
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      url = URI.parse("https://api2.dynect.net/REST/#{path}")
      http = Net::HTTP.new(url.host, url.port) 
      http.set_debug_output $stderr 
      http.use_ssl = true
      resp, data = nil, nil
      begin
        resp, data = http.delete(url.path, headers)
        Libra.logger_debug "DEBUG: DYNECT DELETE Response: #{data}"
      rescue Exception => e        
        raise_dns_exception(e)
      end
      return resp, data
    end        

    #
    # Configures the user on this server
    #
    def create_user(user)
      # Make the call to configure the user
      #execute_internal(@@C_CONTROLLER, 'configure', "-c #{user.uuid} -e #{user.rhlogin} -s #{user.ssh}")
      execute_direct(@@C_CONTROLLER, 'configure', "-c #{user.uuid} -e #{user.rhlogin} -s #{user.ssh}")
    end

    #
    # Returns whether this server has the specified app
    #
    def has_app?(user, app_name)
      Helper.rpc_exec('libra') do |client|      
        client.has_app(:customer => user.uuid,
                        :application => app_name) do |response|
          #return_code = response[:body][:data][:exitcode]
          output = response[:body][:data][:output]
          return output
        end
      end
    end    

    #
    # Configures the application for this user on this server
    #
    def execute(framework, action, app_name, user)
      # Make the call to configure the application
      Libra.client_debug "DEBUG: Executing framework:#{framework} action:#{action} app_name:#{app_name} user:#{user}" if Libra.c[:rpc_opts][:verbose]
      execute_internal(framework, action, "#{app_name} #{user.namespace} #{user.uuid}")
    end

    #
    # Execute cartridge directly on a node
    #
    def execute_direct(cartridge, action, args)
        mc_args = { :cartridge => cartridge,
                    :action => action,
                    :args => args }
        rpc_client = Helper.rpc_exec_direct('libra')
        rpc_client.custom_request('cartridge_do', mc_args, self.name, {'identity' => self.name})
    end

    #
    # Execute the cartridge and action on this server
    #
    def execute_internal(cartridge, action, args)
      Helper.rpc_exec('libra', name) do |client|
        cartridge_do(client, cartridge, action, args)
      end
    end

    #
    # Execute an action on many nodes based by fact
    #
    def self.execute_many(cartridge, action, args, fact, value, operator="==")
        options = Libra.c[:rpc_opts]
        options[:filter]['fact'] = [{:value=>value, :fact=>fact, :operator=>operator}]
        p options if Libra.c[:rpc_opts][:verbose]
        Helper.rpc_exec('libra') do |client|
          cartridge_do(client, cartridge, action, args)
        end
    end
    
    def self.cartridge_do(client, cartridge, action, args)
      client.cartridge_do(:cartridge => cartridge,
                          :action => action,
                          :args => args) do |response|
        return_code = response[:body][:data][:exitcode]
        output = response[:body][:data][:output]

        Libra.client_debug "DEBUG: Cartridge return code: #{return_code}" if Libra.c[:rpc_opts][:verbose]
        Libra.client_debug "DEBUG: Cartridge output: #{output}" if Libra.c[:rpc_opts][:verbose]
        raise CartridgeException.new(141), output, caller[0..5] if return_code != 0
      end
    end

    #
    # Returns the number of repos that the server has
    # looking it up if needed
    #
    def repos
      # Only call out to MCollective if the value isn't set
      Helper.rpc_get_fact('git_repos', name) do |server, repos|
        @repos = repos
      end unless @repos

      @repos
    end

    #
    # Returns the requested fact
    #
    def get_fact_direct(fact)
        Helper.rpc_get_fact_direct(fact, self.name)
    end

    #
    # Clears out any cached data
    #
    def reload
      @repos = nil
    end

    #
    # Base equality on the server name
    #
    def ==(another_server)
      self.name == another_server.name
    end

    #
    # Base sorting on the server name
    #
    def <=>(another_server)
      self.name <=> another_server.name
    end
  end
end
