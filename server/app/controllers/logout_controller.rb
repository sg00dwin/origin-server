require 'pp'

class LogoutController < ApplicationController
  def index
    reset_session
    Rails.logger.debug "Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
    cookies.delete :rh_sso, :domain => '.redhat.com'
    redirect_to login_index_path
  end
end
