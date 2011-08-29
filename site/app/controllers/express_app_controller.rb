require 'net/http'
require 'uri'
require 'cgi'

class ExpressAppController < ApplicationController
  before_filter :require_login
  
  @@max_tries = 5000
  
  def create
    app_params = params[:express_app] # Get the params we're interested in
    @app = ExpressApp.new app_params
    @app.ticket = session[:ticket]
    if @app.valid?
      @app.configure
      if @app.errors[:base].blank?
        # Get updated userinfo
        @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
        @userinfo.establish
        @message = I18n.t('express_api.messages.app_created')
        @message_type = :success
        # Check app is available
        #Rails.logger.debug "Checking health..."
        #check_app_health
      else
        @message = @app.errors.full_messages.join("; ")
        @message_type = :error
      end
    else
      @message = @app.errors.full_messages.join("; ")
      @message_type = :error
    end
        
    # Respond based on requested format
    Rails.logger.debug "Responding to app creation"
    @max_apps = Rails.configuration.express_max_apps
=begin
    @health_url = "http://#{app_url}"
    @health_url << "/#{@app.health_path}" unless @app.health_path.nil?
    @check_url = url_for :controller => 'express_app', :action => 'health_check'
=end
    respond_to do |format|
      format.html {flash[@message_type] = @message; redirect_to :controller => 'control_panel'}
      format.js
    end
  end
  
  def check_app_health
    health_url = URI.parse("http://#{app_url}/#{@app.health_path}")
    Rails.logger.debug "Health URL: #{health_url}"
    #sleep_time = 2
    try = 0
    while try < @@max_tries
      try += 1
      Rails.logger.debug "Try number #{try}"
      # Test app health
      begin
        res = Net::HTTP.get_response(health_url)
      rescue
        res = nil
      end
      # Check response is as expected
      if !res.nil? and res.code == '200' and res.body[0,1] == '1'
        Rails.logger.debug "App is available!"
        @message = I18n.t('express_api.messages.app_available')
        @message_type = :success
        return
      end
      
      # Sleep for a bit and try again
      #sleep_time *= 2 # double sleep time
      #sleep sleep_time
    end

    Rails.logger.debug "App unavailable :("
    @message = I18n.t('express_api.errors.app_unavailable')
    @message_type = :error
    Rails.logger.debug "Finished checking health"
  end
  
  def app_url
    if @userinfo.namespace and @userinfo.rhc_domain and @app
      "#{@app.app_name}-#{@userinfo.namespace}.#{@userinfo.rhc_domain}"
    end
  end
  
  def health_check
    begin
      health_url = URI.parse(params[:url])
    rescue Exception => e
      Rails.logger.error "Exception when parsing url #{params[:url]} - #{e.message}"
      health_url = nil
    end
    unless health_url.nil?
      begin
        res = Net::HTTP.get_response(health_url)
      rescue Exception => e
        Rails.logger.error "Exception when requesting #{health_url}: #{e.message}"
        res = nil
      end
    end
    Rails.logger.debug "Response from #{health_url}: #{res.inspect}"
    response = {
      :status => res.nil? ? '0' : res.code,
      :body => res.nil? ? '' : res.body[0,1]
    }
    render :text => (ActiveSupport::JSON.encode response)
  end

end
