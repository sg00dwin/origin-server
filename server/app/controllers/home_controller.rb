class HomeController < ApplicationController
  def index
    # Handle any workflow routing
    if session[:workflow]
      redirect_to session[:workflow]
      session[:workflow].clear
    end

    # If the user is logged in, send them to the landing page
    # otherwise, send them to the home
    if session[:login]
      render "protected/index"
    else
      render :index
    end
  end

  def getting_started; end
end
