class GettingStarted::FlexController < ApplicationController
  before_filter :set_no_cache
  
  def show
    if !session[:login]
      session[:workflow] = getting_started_flex_path
      redirect_to login_path and return
    end    
  end
end
