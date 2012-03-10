class SiteController < ApplicationController

  layout 'site'

  before_filter :new_forms, :only => [ :show, :signup, :signin ]

  def index
    Rails.logger.debug "Index controller"
    # Handle any workflow routing
    Rails.logger.debug "Session workflow in HomeController#index: #{workflow}"
    if workflow_redirect
      return
    end
  end

  def overview
  end

  def express
  end

  def flex
  end

  def signin
    render :layout => 'box'
  end

  def signup
    render :layout => 'box'
  end

  def recover
    render :layout => 'box'
  end

  def success
    render :layout => 'box'
  end

end
