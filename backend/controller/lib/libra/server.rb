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
      current_server, current_repos = nil, 100000000

      Helper.rpc_get_fact('git_repos') do |server, repos|
        num_repos = repos.to_i
        if num_repos < current_repos
          current_server = server
          current_repos = num_repos
        end
      end
      throw :no_servers_found unless current_server
      puts "DEBUG: server.rb:find_available #{current_server}: #{current_repos}" if Libra.c[:rpc_opts][:verbose]
      new(current_server, current_repos)
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
"server #{@@config[:resolver]}
zone #{@@config[:libra_domain]}
update delete #{host}.#{@@config[:libra_domain]}
update add #{host}.#{@@config[:libra_domain]} 60 A #{public_ip}
update add #{host}.#{@@config[:libra_domain]} 60 SSHFP 1 1 #{sshfp}
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
"server #{@@config[:resolver]}
zone #{@@config[:libra_domain]}
update delete #{host}.#{@@config[:libra_domain]}
send"
EOF

      execute_nsupdate(nsupdate_input_template)
    end

    #
    # Add a DNS txt entry for new namespace
    #
    def self.nsupdate_add_txt(namespace)
      nsupdate_input_template = <<EOF
"server #{@@config[:resolver]}
zone #{@@config[:libra_domain]}
update delete #{namespace}.#{@@config[:libra_domain]}
update add #{namespace}.#{@@config[:libra_domain]} 60 TXT 'Text record for #{namespace}'
send"
EOF

      execute_nsupdate(nsupdate_input_template)
    end

    def self.execute_nsupdate(nsupdate_input_template)
      nsupdate_string = eval nsupdate_input_template
      puts "DEBUG: server.rb:self.execute_nsupdate nsupdate_input_template: #{nsupdate_input_template}" if Libra.c[:rpc_opts][:verbose]

      IO.popen("/usr/bin/nsupdate -L0 -v -y '#{@@config[:secret]}'", 'w'){ |io| io.puts nsupdate_string }
    end

    #
    # Get a DNS txt entry
    #
    def self.get_dns_txt(namespace)
      dns = Resolv::DNS.new
      resp = dns.getresources("#{namespace}.#{@@config[:libra_domain]}", Resolv::DNS::Resource::IN::TXT)
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
    # Configures the application for this user on this server
    #
    def execute(framework, action, app_name, user)
      # Make the call to configure the application
      puts "DEBUG: server.rb:execute framework:#{framework} action:#{action} app_name:#{app_name} user:#{user}" if Libra.c[:rpc_opts][:verbose]
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
        rpc_client.custom_request('cartridge_do', mc_args, {'identity' => self.name})
    end

    #
    # Execute the cartridge and action on this server
    #
    def execute_internal(cartridge, action, args)
      Helper.rpc_exec('libra', name) do |client|
        client.cartridge_do(:cartridge => cartridge,
                            :action => action,
                            :args => args) do |response|
          return_code = response[:body][:data][:exitcode]
          output = response[:body][:data][:output]

          puts "DEBUG: server.rb:execute_internal return_code: #{return_code}" if Libra.c[:rpc_opts][:verbose]
          puts "DEBUG: server.rb:execute_internal output: #{output}" if Libra.c[:rpc_opts][:verbose]

          raise CartridgeException, output if return_code != 0
        end
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
        client.cartridge_do(:cartridge => cartridge,
                            :action => action,
                            :args => args) do |response|
          return_code = response[:body][:data][:exitcode]
          output = response[:body][:data][:output]

          puts "DEBUG: server.rb:execute_internal return_code: #{return_code}" if Libra.c[:rpc_opts][:verbose]
          puts "DEBUG: server.rb:execute_internal output: #{output}" if Libra.c[:rpc_opts][:verbose]
          raise CartridgeException, output if return_code != 0
        end
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
