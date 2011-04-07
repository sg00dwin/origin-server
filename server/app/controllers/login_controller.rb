require 'pp'

class LoginController < ApplicationController

  def index
    @redirectUrl = "https://openshift.redhat.com/app"
    @errorUrl = "https://openshift.redhat.com/app/login/error"
    Rails.logger.debug "Session workflow in LoginController#index: #{session[:workflow]}"
  end

  def show
    #TODO - better error handling
    @user = WebUser.new
    @user.errors[:error] << "- Invalid username or password"
    render :index
  end

  def create
    Rails.logger.warn "Non integrated environment - faking login"
    session[:login] = params['login']
    session[:ticket] = "test"
    cookies[:rh_sso] = {
        :value => 'test',
        :domain => '.redhat.com'
    }

    Rails.logger.debug "Session workflow in LoginController#create: #{session[:workflow]}"
    Rails.logger.debug "Redirecting to home#index"    
    redirect_to root_path
  end
end
