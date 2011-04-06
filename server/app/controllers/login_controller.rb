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
end
