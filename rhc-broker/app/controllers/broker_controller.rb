require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openssl'
require 'date'
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
      #
      if params['json_data'].nil?
        raise Exception.new("Required param 'nurture_action' not found") unless params['nurture_action']
        action = params['nurture_action']
        if action=="update_last_access"
          gear_timestamps = params['gear_timestamps']
          raise Exception.new("Required param 'gear_timestamps' not found for action 'update_last_access") if gear_timestamps.nil?
          bulk_update_array = []
          app_uuid_hash = {}
          gear_timestamps.each { |gear_data|
            next if not gear_data.has_key?("access_time")
            next if not gear_data.has_key?("uuid")
            gear_uuid = gear_data["uuid"]
            begin
              time_object = DateTime.strptime(gear_data["access_time"], "%d/%b/%Y:%H:%M:%S %Z")
            rescue
              Rails.logger.error("Invalid format for access_time '#{gear_data["access_time"]}'. Needs to be %d/%b/%Y:%H:%M:%S %Z")
              next 
            end
            # Nurture stores everything in Pacific Time
            access_time = time_object.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S")
            app, gear = Application::find_by_gear_uuid(gear_uuid)
            if app.nil?
              Rails.logger.error("Invalid gear uuid #{gear_uuid}")
              next
            end
            app_data = { "app_uuid" => app.uuid, "column_name" => "last_accessed_at", "column_value" => access_time }
            if not app_uuid_hash.has_key?(app.uuid)
              bulk_update_array << app_data 
              app_uuid_hash[app.uuid] = 1
            end
          }
          Online::Broker::Nurture.application_bulk_update(bulk_update_array)
        end
      else
        data = parse_json_data(params['json_data'])
        return unless data
        action = data['action']
        app_uuid = data['app_uuid']
        Online::Broker::Nurture.application_update(action, app_uuid)
      end
  
      # Just return a 200 success
      render :json => generate_result_json("Success") and return
      
    rescue Exception => e
      Rails.logger.debug "Exception in nurture post: #{e.message}"
      Rails.logger.debug e.backtrace.inspect
      render :json => generate_result_json(e.message, nil, e.respond_to?('exit_code') ? e.exit_code : 1), :status => :internal_server_error
    end
  end
end
