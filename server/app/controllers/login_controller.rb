require 'pp'

class LoginController < ApplicationController

  def index
    @redirectUrl = "http://openshift.redhat.com/app"
    @errorUrl = "http://openshift.redhat.com/app/login/error"
  end

  def create
    @user = WebUser.new(params[:web_user])
    Rails.logger.debug "Logging in user #{user}"

    @user.login

    render and return if @user.errors.any?

    Rails.logger.debug "User is logged in"

    # Redirect to a running workflow if it exists
    if session[:workflow]
      Rails.logger.debug "Found existing workflow, redirecting to #{session[:workflow]}"
      redirect_to session[:workflow] if session[:workflow]
    else
      Rails.logger.debug "No existing workflow, redirecting to landing page"
      redirect_to landing_index_path, :protocol => "https"
    end
  end

  def show
    #TODO - better error handling
    @user = WebUser.new
    @user.errors[:error] << "- Invalid username or password"
    render :index
  end
end
