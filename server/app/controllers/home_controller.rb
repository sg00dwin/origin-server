class HomeController < ApplicationController
  def index
    Rails.logger.debug "Index controller"
    # Handle any workflow routing
    Rails.logger.debug "Session workflow in HomeController#index: #{session[:workflow]}" 
    if session[:workflow]
      workflow = session[:workflow]
      session[:workflow] = nil
      redirect_to workflow and return
    else
      # If workflow didn't send them elsewhere then they go to the index.      
      # Assuming at some point news will come from a news source
      @news = [ 'Lorem ipsum dolor si',
                'Amet, consetetur sadipscing elitr, sed diam nonumyeirmod',
                'Tempor invidunt ut labore et dolore magna aliquyam erat, sed' ]
    end
  end

  def getting_started
    if !session[:login]
      session[:workflow] = getting_started_path
      redirect_to login_index_path and return
    end
  end
end
