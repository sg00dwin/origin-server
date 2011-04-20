class GettingStarted::ExpressController < ApplicationController
  before_filter :set_no_cache
  
  def show
    if !session[:login]
      session[:workflow] = getting_started_express_path
      redirect_to login_path and return
    end
  end
end
