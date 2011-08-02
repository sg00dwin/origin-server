class GettingStarted::GenericController < ApplicationController
  before_filter :set_no_cache
  
  def show
    if !session[:login]
      session[:login_workflow] = getting_started_path
      redirect_to login_path, :notice => flash[:notice] and return
    else
      redirect_to root_path
    end
  end
end
