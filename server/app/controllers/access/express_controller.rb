require 'pp'

class Access::ExpressController < ApplicationController

  def index
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
      Rails.logger.debug "Requesting Express access for user #{user}"
      user.request_access(CloudAccess::EXPRESS)
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_access_express_path
      redirect_to login_index_path
    end
  end
end
