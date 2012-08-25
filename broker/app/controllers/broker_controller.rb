require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openssl'                                                                                                                                                                                              
require 'digest/sha2'
require 'base64'

class BrokerController < ApplicationController
  include ApplicationHelper

  layout nil
  
  def generate_result_json(result, data=nil, exit_code=0)      
      json = JSON.generate({
                  :result => result,
                  :data => data,
                  :exit_code => exit_code
                  })
      json
  end
  
  def parse_json_data(json_data)
    data = JSON.parse(json_data)

    # Validate known json vars.  Error on unknown vars.
    data.each do |key, val|
      case key
        when 'app_uuid'
          if !(val =~ /\A[a-f0-9]+\z/)
            render :json => generate_result_json("Invalid application uuid: #{val}", nil, 1), :status => :bad_request and return nil
          end
        when 'action'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid #{key} specified: #{val}", nil, 111), :status => :bad_request and return nil
          end
        else
          render :json => generate_result_json("Unknown json key found: #{key}", nil, 1), :status => :bad_request and return nil
      end
    end if data
    data
  end

  def nurture_post
    begin
      # Parse the incoming data
      raise Exception.new("Required params 'app_uuid', 'action' not found") unless params['json_data']
      data = parse_json_data(params['json_data'])
      return unless data
      action = data['action']
      app_uuid = data['app_uuid']
      Express::Broker::Nurture.application_update(action, app_uuid)
      Express::Broker::Apptegic.application_update(action, app_uuid)
  
      # Just return a 200 success
      render :json => generate_result_json("Success") and return
      
    rescue Exception => e
      Rails.logger.debug "Exception in nurture post: #{e.message}"
      Rails.logger.debug e.backtrace.inspect
      render :json => generate_result_json(e.message, nil, e.respond_to?('exit_code') ? e.exit_code : 1), :status => :internal_server_error
    end
  end
end
