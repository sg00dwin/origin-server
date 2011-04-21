# file: Serves home + static pages

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
    end
  end

  # Hijacking home controller
  # for general static page serving
  def about; end
end
