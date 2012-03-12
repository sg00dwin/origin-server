# file: Serves home + static pages

class HomeController < ApplicationController
  
  layout 'site'

  def index
    Rails.logger.debug "Index controller"
    # Handle any workflow routing
    Rails.logger.debug "Session workflow in HomeController#index: #{workflow}"
    if workflow_redirect
      return
    end
  end
  
  # Hijacking home controller
  # for general static page serving
  def about; end

  def getting_started; end

end
