require 'uri'

class ProductController < ApplicationController

  def express
    # Handle the email confirmation flow
    @product = 'express'
    
    if session[:confirm_flow]
      session.delete(:confirm_flow)
      flash[:notice] = "Almost there!  Login to complete your registration."
      require_login and return
    end
  end
  
  def flex_redirect
    case try_it_destination(CloudAccess::FLEX)
    when 'register'
      session[:workflow] = '/app/user/new/flex'
    when 'queue', 'request'
      session[:login_workflow] = '/app/flex'
    when 'getting_started'
      session[:login_workflow] = '/app/flex#quickstart'
    end
    redirect_to '/flex' and return
  end
  
  def flex
    @product = 'flex'
    
    # Handle the email confirmation flow
    if session[:confirm_flow]
      session.delete(:confirm_flow)
      flash[:notice] = "Almost there!  Login to complete your registration."
      require_login and return
    elsif workflow_redirect
      # Handles flex redirecting back to /app/flex
      return
    end
  end

  def power
    @product = 'power'
  end
end
