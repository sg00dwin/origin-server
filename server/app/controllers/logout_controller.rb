class LogoutController < ApplicationController
  def index
    reset_session
    cookies.delete :rh_sso, :domain => '.redhat.com'
    redirect_to login_index_path
  end
end
