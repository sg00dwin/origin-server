require 'pp'

class LoginController < ApplicationController

  def index
    @redirectUrl = "https://openshift.redhat.com/app"
    @errorUrl = "https://openshift.redhat.com/app/login/error"
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
    cookie[:rh_sso] = "test"

    redirect_to protected_path
  end
end
