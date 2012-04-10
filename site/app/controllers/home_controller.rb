# file: Serves home + static pages

class HomeController < SiteController

  def index
    Rails.logger.debug "Index controller"
    # Handle any workflow routing
    Rails.logger.debug "Session workflow in HomeController#index: #{workflow}"
    if workflow_redirect
      return
    end
  end

end
