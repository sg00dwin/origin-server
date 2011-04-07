require 'pp'

class Access::FlexController < ApplicationController

  def index
    Rails.logger.debug "Checking login status"    
    login = session[:login]    
    
    if login      
      @access_flex = Access::Flex.new
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = access_flexes_path
      redirect_to login_index_path, :notice => "You'll need to login / register before asking for access"
    end
  end

  def new
    create
  end

  def create
    Rails.logger.debug "Checking login status"
    login = session[:login]    
    if login      
      Rails.logger.debug "User is logged in"
      @access_flex = Access::Flex.new(params[:access_flex])
      render :index and return unless @access_flex.valid?
      user = WebUser.find_by_ticket(session[:ticket])      
      Rails.logger.debug "Requesting Flex access for user #{user}"
      user.request_access(CloudAccess::FLEX, @access_flex.ec2AccountNumber)
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_flex_path
      redirect_to login_index_path
    end
  end
end
