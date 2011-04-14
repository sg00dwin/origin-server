require 'pp'

class LogoutController < ApplicationController
  def show
    reset_session
    Rails.logger.debug "Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
    cookies.delete :rh_sso, :domain => '.redhat.com'
    session.clear
    redirect_to login_path
  end
end
