require 'mcollective'

class ResultIO
  attr_accessor :debugIO, :resultIO, :messageIO, :errorIO, :appInfoIO
  
  def initialize
    debugIO = StringIO.new
    resultIO = StringIO.new
    messageIO = StringIO.new
    errorIO = StringIO.new
    appInfoIO = StringIO.new
  end
  
  def append(resultIO)
    self.debugIO << resultIO.debugIO.string
    self.resultIO << resultIO.resultIO.string
    self.messageIO << resultIO.messageIO.string
    self.errorIO << resultIO.errorIO.string
    self.appInfoIO << resultIO.appInfoIO.string
    self
  end
end

include MCollective::RPC
class ApplicationContainerProxy
  @@C_CONTROLLER = 'li-controller'
  
  def self.find_available(node_profile="std")
    current_server, current_capacity = rpc_find_available(node_profile)
    Rails.logger.debug "CURRENT SERVER: #{current_server}"
    if !current_server
      current_server, current_capacity = rpc_find_available(node_profile, true)
      Rails.logger.debug "CURRENT SERVER: #{current_server}"
    end
    raise Cloud::Sdk::NodeException.new("No nodes available.  If the problem persists please contact Red Hat support.", 140), caller[0..5] unless current_server
    Rails.logger.debug "DEBUG: server.rb:find_available #{current_server}: #{current_capacity}"
    
    current_server
  end
  
  IGNORE_CARTS = %w(abstract abstract-httpd li-controller embedded)
  def self.get_available_cartridges(cart_type)
    server_id = find_available()
    cartridges = []
    
    case cart_type
    when 'standalone'
      rpc_get_fact('cart_list', server_id) do |server, carts|
        cartridges = carts.split('|')
      end
    when 'embedded'
      rpc_get_fact('embed_cart_list', server_id) do |server, embedcarts|
        cartridges = embedcarts.split('|')
      end
    end
    cartridges.delete_if {|cart| IGNORE_CARTS.include?(cart)}
    
    cartridges
  end
  
  def self.create(app)
    result = execute_direct(@@C_CONTROLLER, 'configure', "-c '#{app.uuid}' -s '#{app.user.ssh}'")
    parse_result(result)
  end
  
  def add_authorized_ssh_key(app, ssh_key)
    result = execute_direct(@@C_CONTROLLER, 'add-authorized-ssh-key', "-c #{app.uuid} -s #{ssh_key}")
    parse_result(result)
  end
  
  def remove_authorized_ssh_key(app, ssh_key)
    result = execute_direct(@@C_CONTROLLER, 'add-authorized-ssh-key', "-c #{app.uuid} -s #{ssh_key}")
    parse_result(result)
  end
  
  def self.destroy(app)
    result = execute_direct(@@C_CONTROLLER, 'deconfigure', "-c '#{app.uuid}'")
    parse_result(result)
  end

  def self.add_env_var(app, key, value)
    result = execute_direct(@@C_CONTROLLER, 'add-env-var', "-c #{app.uuid} -k #{key} -v #{value}")
    parse_result(result)
  end
  
  def self.remove_env_var(app, key, value)
    result = execute_direct(@@C_CONTROLLER, 'remove-env-var', "-c #{app.uuid} -k #{key} -v #{value}")
    parse_result(result)    
  end

  def self.add_broker_auth_key(app, id, token)
    result = execute_direct(@@C_CONTROLLER, 'add-broker-auth-key', "-c #{app.uuid} -i #{id} -t #{token}")
    parse_result(result)
  end

  def self.remove_broker_auth_key(app)
    result = execute_direct(@@C_CONTROLLER, 'remove-broker-auth-key', "-c #{app.uuid}")
    handle_controller_result(result)
  end
  
  def self.preconfigure_cartridge(app, cart)
    self.run_cartridge_command(cart, app, "preconfigure")
  end
  
  def self.configure_cartridge(app, cart)
    self.run_cartridge_command(cart, app, "configure")
  end
  
  private
  
  def self.run_cartridge_command(framework, app, command)
    result = execute_direct(framework, "configure", "'#{app.name}' '#{app.user.namespace}' '#{app.uuid}'")[0]
    if (result && defined? result.results && result.results.has_key?(:data))
      output = result.results[:data][:output]
      exitcode = result.results[:data][:exitcode]
      
      resultIO = parse_result(output)
      if exitcode != 0
        debug += "Cartridge return code: " + exitcode.to_s
        raise Cloud::Sdk::NodeException.new("Node execution failure (invalid exit code from node).  If the problem persists please contact Red Hat support.", 143), caller[0..5]
      end
    else
      raise Cloud::Sdk::NodeException.new("Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", 143), caller[0..5]
    end
    return resultIO    
  end
  
  def self.rpc_find_available(node_profile="std", forceRediscovery=false)
    current_server, current_capacity = nil, nil
    additional_filters = [
      {:fact => "node_profile",
       :value => node_profile,
       :operator => "=="},
      {:fact => "capacity",
       :value => "100",
       :operator => "<"
      }
    ]

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
  
  def execute_direct(cartridge, action, args)
      mc_args = { :cartridge => cartridge,
                  :action => action,
                  :args => args }
      rpc_client = rpc_exec_direct('libra')
      result = nil
      begin
        result = rpc_client.custom_request('cartridge_do', mc_args, self.name, {'identity' => self.name})
      ensure
        rpc_client.disconnect
      end
      Rails.logger.debug result
      result
  end
  
  def parse_result(output)
    result = ResultIO.new
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
        else # exitcode != 0
          result.debugIO << line
          Rails.logger.debug "DEBUG: server results: " + line
        end
      end
      
      #TODO
      #elsif exitcode == 0 && user && app_name
      #  if line =~ /^SSH_KEY_(ADD|REMOVE): /
      #    if line =~ /^SSH_KEY_ADD: /
      #      key = line['SSH_KEY_ADD: '.length..-1].chomp
      #      user.set_system_ssh_key(app_name, key)
      #    else
      #      user.remove_system_ssh_key(app_name)
      #    end
      #  elsif line =~ /^ENV_VAR_(ADD|REMOVE): /
      #    if line =~ /^ENV_VAR_ADD: /
      #      env_var = line['ENV_VAR_ADD: '.length..-1].chomp.split('=')
      #      user.set_env_var(app_name, env_var[0], env_var[1])
      #    else
      #      key = line['ENV_VAR_REMOVE: '.length..-1].chomp
      #      user.remove_env_var(app_name, key)
      #    end
      #  elsif app && line =~ /^BROKER_AUTH_KEY_(ADD|REMOVE): /
      #    if line =~ /^BROKER_AUTH_KEY_ADD: /
      #      user.set_broker_auth_key(app_name, app)
      #    else
      #      user.remove_broker_auth_key(app_name, app)
      #    end
      #  end
    end
    result
  end
  
  def self.rpc_options
    # Make a deep copy of the default options
    Marshal::load(Marshal::dump(Rails.application.config.cdk[:rpc_opts]))
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

  def self.rsuccess(response)
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
  def self.rpc_get_fact_direct(fact, node)
      options = rpc_options

      rpc_client = rpcclient("rpcutil", :options => options)
      begin
        result = rpc_client.custom_request('get_fact', {:fact => fact}, node, {'identity' => node})[0]
        if (result && defined? result.results && result.results.has_key?(:data))
          value = result.results[:data][:value]
        else
          raise NodeException.new(143), "Node execution failure (error getting fact).  If the problem persists please contact Red Hat support.", caller[0..5]
        end
      ensure
        rpc_client.disconnect
      end

      return value
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

  #
  # Execute direct rpc call directly against a node
  # If more then one node exists, just pick one
  def self.rpc_exec_direct(agent)
      options = rpc_options
      rpc_client = rpcclient(agent, :options => options)
      Rails.logger.debug("DEBUG: rpc_exec_direct: rpc_client=#{rpc_client}")
      rpc_client
  end
end