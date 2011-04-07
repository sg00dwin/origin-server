require 'pp'

class Access::FlexController < ApplicationController

  def index
    @user = WebUser.new
    
    Rails.logger.debug "Checking login status"
    login = session[:login]

    if login
      Rails.logger.debug "User is logged in"
      user = WebUser.find_by_ticket(session[:ticket])
      Rails.logger.debug "Requesting Flex access for user #{user}"
      user.request_access(CloudAccess::FLEX)
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = access_express_index_path
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
      user = WebUser.find_by_ticket(session[:ticket])
      Rails.logger.debug "Requesting Flex access for user #{user}"
      user.request_access(CloudAccess::FLEX)
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_express_path
      redirect_to login_index_path
    end
  end
end
