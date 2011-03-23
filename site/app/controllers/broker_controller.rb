require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'libra'

include Libra

class BrokerController < ApplicationController  
  
  def generate_result_json(result)      
      json = JSON.generate({
                  :debug => Thread.current[:debugIO].string,
                  :result => result
                  })
      json
  end
  
  def parse_json_data(json_data)
    data = JSON.parse(json_data)
    thread = Thread.current
    thread[:debugIO] = StringIO.new # Need to find a better way to do this.  Object structure for request would work.  Perhaps there is something more elegant built into rails?
    if (data['debug'])
      Libra.c[:rpc_opts][:verbose] = true       
    end
    data
  end

  def cartridge_post
      # Parse the incoming data
      data = parse_json_data(params['json_data'])

      # Execute a framework cartridge
      Libra.execute(data['cartridge'], data['action'], data['app_name'], data['rhlogin'], data['password'])         

      render :json => generate_result_json("Success")
      # TODO handle errors 
  end
  
  def user_info_post
    # Parse the incoming data
    data = parse_json_data(params['json_data'])

    # Check if user already exists
    if User.valid_registration?(data['rhlogin'], data['password'])
      user = User.find(data['rhlogin'])
      if user
        user_info = {
            :rhlogin => user.rhlogin,
            :uuid => user.uuid,
            :namesdebugpace => user.namespace,
            :ssh_key => user.ssh
            }                
        app_info = {}
        
        user.apps.each do |key, app|
            app_info[key] = {
                :framework => app['framework'],
                :creation_time => app['creation_time']
            }
        end
        
        json_data = JSON.generate({:user_info => user_info,
           :app_info => app_info})
        
        render :json => generate_result_json(json_data)
      else
        # Return a 404 to denote the user doesn't exist
        render :json => generate_result_json("User does not exist"), :status => :not_found
      end
    else
      Libra.debug "Invalid user credentials"
      render :json => generate_result_json("Invalid user credentials"), :status => :unauthorized
    end    
  end
  
  def domain_post 
    # Parse the incoming data
    data = parse_json_data(params['json_data'])
                      
    user = User.find(data['rhlogin'])
    if user
      if data['alter']
        user.namespace=data['namespace']
        user.ssh=data['ssh']
        user.update
        Server.execute_many('li-controller-0.1', 'configure',
            "-c #{user.uuid} -e #{user.rhlogin} -s #{user.ssh}",
            "customer_#{user.rhlogin}", user.rhlogin)
      else
        render :json => generate_result_json("User already has a registered namespace.  To overwrite or change, use --alter"), :status => :conflict
      end
    else
      if User.valid_registration?(data['rhlogin'], data['password'])
        user = User.create(data['rhlogin'], data['ssh'], data['namespace'])
      else
        render :json => generate_result_json("Invalid user credentials"), :status => :unauthorized
      end
    end

    json_data = JSON.generate({
                            :rhlogin => user.rhlogin,
                            :uuid => user.uuid
                            })
                                                                
    # Just return a 200 success
    render :json => generate_result_json(json_data)
    # TODO handle errors
  end
end
