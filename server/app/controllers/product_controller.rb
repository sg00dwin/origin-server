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
      session[:workflow] = '/app/access/flex/request'
    when 'getting_started'
      session[:workflow] = '/app/getting_started/flex'
    end
    redirect_to '/flex' and return
  end
  
  def flex
    # Hack for the flex authentication handling
    workflow = session[:workflow]
    logger.debug "Flex workflow = #{workflow}"
    if workflow
      session[:workflow] = nil
      redirect_to workflow and return
    end
    
    @product = 'flex'
    @try_link_points_to = try_it_destination(CloudAccess::FLEX)
    return
  end

  def power
    @product = 'power'
    render :layout => 'application'
  end
  
  
end
