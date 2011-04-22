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
      # How to present the try it link on the home page
      @try_link_points_to = try_it_destination(CloudAccess::EXPRESS)
      # If workflow didn't send them elsewhere then they go to the index.
    end
  end

  # Hijacking home controller
  # for general static page serving
  def about; end
end
