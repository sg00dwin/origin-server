require 'pp'

class Access::ExpressRequestController < ApplicationController
  before_filter :set_no_cache

  def new
    Rails.logger.debug "Checking login status"
    login = session[:login]
    if login
      @access_express = Access::ExpressRequest.new
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_express_requests_path
      redirect_to login_path, :notice => "You'll need to login / register before asking for access"
    end
  end

  def create
    Rails.logger.debug "Checking login status"
    login = session[:login]

    if login
      Rails.logger.debug "User is logged in"
      ae = params[:access_express_request]
      @access_express = Access::ExpressRequest.new(ae ? ae : {})
      render :new and return unless @access_express.valid?
      user = WebUser.find_by_ticket(session[:ticket])
      Rails.logger.debug "Requesting Express access for user #{user}"      
      user.request_access(CloudAccess::EXPRESS)
      @access_express.errors.update(user.errors)
      render :new and return unless @access_express.errors.length == 0
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_express_path
      redirect_to login_path
    end
  end
end
