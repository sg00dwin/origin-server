class GettingStarted::ExpressController < ApplicationController
  before_filter :set_no_cache
  
  def show
    if !session[:login]
      session[:login_workflow] = getting_started_express_path
      redirect_to login_path and return
    else
      user = session_user
      user.refresh_roles
      redirect_to new_access_express_requests_path unless user.has_access?(CloudAccess::EXPRESS)
      @domain = ExpressDomain.new()
    end
  end
end
