require 'rest-client'

module GearChanger
  class Apptegic
    #
    # Send application data (start, stop, etc)
    #
    def self.application(login, user_uuid, app_name, user_namespace, type, action, app_uuid)
      return unless Rails.configuration.analytics[:apptegic_enabled]
      Rails.logger.debug "DEBUG: #{Time.now} Sending to Apptegic:application: user='#{login}' app_uuid='#{app_uuid}' action='#{action}'"

      url =  Rails.configuration.analytics[:apptegic_url]
      payload = {}
      payload["_ak"] = Rails.configuration.analytics[:apptegic_key]
      payload["_at"] = Rails.configuration.analytics[:apptegic_secret]
      payload["_ds"] = Rails.configuration.analytics[:apptegic_dataset]
      payload["userAgent"] = Thread.current[:user_agent] || "Unknown"
      payload["accountId"] = login
      payload["accountType"] = "regular"
      payload["userId"] = login
      payload["user_uuid"] = user_uuid
      payload["app_uuid"] = app_uuid
      payload["app_name"] = app_name
      payload["app_type"] = type
      payload["action"] = action
      payload["platform"] = "express"

      headers = {"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8" }
      
      request = RestClient::Request.new(:method => :post, :url =>url, :payload => payload, :headers => headers)
      
      # for non-blocking
      thread = Thread.new(request){
        begin
          response = request.execute
          Rails.logger.debug "Response from apptegic: #{response.code}"
        rescue RestClient::ExceptionWithResponse => e
          Rails.logger.error "Response from apptegic: #{e.response}"
        end
      }
      Rails.logger.debug "DEBUG: #{Time.now} Done sending to Apptegic"
    end
  end
end
