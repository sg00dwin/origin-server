include ActionView::Helpers::UrlHelper

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

  def recover_success
    message 'Password Reset Email Sent', "
      <p>
      An e-mail has been sent to you containing instructions on how to reset your password. 
      The link in the e-mail will allow you to change your password.
      </p>
      <p>
        #{link_to 'Return to the main page', '/app/new'}
      </p>
    "
  end
  
  private
  
  def message(title, content)
    @title = title
    @content = content
    render 'success', :layout => 'box'
  end

end
