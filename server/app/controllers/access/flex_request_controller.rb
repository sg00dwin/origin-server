require 'pp'

class Access::FlexRequestController < ApplicationController
  before_filter :set_no_cache

  def new
    Rails.logger.debug "Checking login status"    
    login = session[:login]    
    
    if login      
      @access_flex = Access::FlexRequest.new
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_flex_requests_path
      redirect_to login_path, :notice => "You'll need to login / register before asking for access"
    end
  end

  def create
    Rails.logger.debug "Checking login status"
    login = session[:login]
    
    if login
      Rails.logger.debug "User is logged in"
      @access_flex = Access::FlexRequest.new(params[:access_flex_request])
      render :new and return unless @access_flex.valid?
      user = WebUser.find_by_ticket(session[:ticket])
      Rails.logger.debug "Requesting Flex access for user #{user}"
      user.request_access(CloudAccess::FLEX, @access_flex.ec2_account_number)
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_flex_requests_path
      redirect_to login_path
    end
  end
end
