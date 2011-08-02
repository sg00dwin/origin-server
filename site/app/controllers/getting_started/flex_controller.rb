class GettingStarted::FlexController < ApplicationController
  before_filter :set_no_cache
  
  def show
    if !session[:login]
      session[:login_workflow] = getting_started_flex_path
      redirect_to login_path and return
    else
      user = session_user
      user.refresh_roles
      unless user.has_access?(CloudAccess::FLEX)
        redirect_to new_access_flex_requests_path 
      else
        redirect_to '/app/flex#quickstart'
      end
    end    
  end
end
