require 'pp'

class LoginController < ApplicationController

  def show
    
    @redirectUrl = root_url
    @errorUrl = login_error_url
    Rails.logger.debug "Session workflow in LoginController#index: #{session[:workflow]}"
    render :index
  end

  def error
    #TODO - better error handling
    @user = WebUser.new
    @user.errors[:error] << "- Invalid username or password"
    show
  end

  def create
    Rails.logger.warn "Non integrated environment - faking login"
    session[:login] = params['login']
    session[:ticket] = "test"
    session[:user] = WebUser.new(:email_address => params['login'])
    cookies[:rh_sso] = 'test'

    Rails.logger.debug "Session workflow in LoginController#create: #{session[:workflow]}"
    Rails.logger.debug "Redirecting to home#index"    
    redirect_to root_path
    #redirect_to login_error_path
  end
end
