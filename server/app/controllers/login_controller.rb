require 'pp'

class LoginController < ApplicationController

  def index
  end

  def create
    user = WebUser.new(params[:web_user])
    Rails.logger.debug "Logging in user #{user}"
    user.login

    # TODO - Handle validation
    if login
      Rails.logger.debug "User is logged in"
    else
      Rails.logger.debug "User is not logged in"
    end

    # Redirect to a running workflow if it exists
    redirect_to session[:workflow] if session[:workflow]
  end
end
