require 'pp'

class LogoutController < ApplicationController
  def show_flex
    @redirect_path = login_flex_path
    show
  end
  
  def show_express
    @redirect_path = login_express_path
    show
  end
  
  def show
    reset_sso
    reset_session
    if params[:redirectUrl]
      session[:login_workflow] = params[:redirectUrl]
    end
    @redirect_path = @redirect_path ? @redirect_path : login_path
    redirect_to @redirect_path
  end
end