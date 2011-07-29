require 'uri'

class ProductController < ApplicationController

  def express
    @product = 'express'
    @try_link_points_to = try_it_destination(CloudAccess::EXPRESS)
  end
  
  def flex_redirect
    case try_it_destination(CloudAccess::FLEX)
    when 'register'
      session[:workflow] = '/app/user/new/flex'
    when 'queue', 'request'
      session[:login_workflow] = '/app/access/flex/request'
    when 'getting_started'
      session[:login_workflow] = '/app/getting_started/flex'
    end
    redirect_to '/flex' and return
  end
  
  def flex
    # Handles flex redirecting back to /app/flex
    if workflow_redirect
      return
    end
    
    @product = 'flex'
    @try_link_points_to = try_it_destination(CloudAccess::FLEX)
    return
  end

  def power
    @product = 'power'
  end
  
  
end
