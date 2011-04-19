# file: Serves home + static pages

class HomeController < ApplicationController
  before_filter :set_no_cache

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

  # Hijacking home controller
  # for general static page serving
  def about; end
end
