class HomeController < ApplicationController
  def index
    # Handle any workflow routing
    if session[:workflow]
      workflow = session[:workflow]
      session[:workflow] = nil
      redirect_to workflow and return
    end

    # If the user is logged in, send them to the landing page
    # otherwise, send them to the home
    if session[:login]
      redirect_to protected_path
    else
      render :index
    end
  end

  def getting_started; end
end
