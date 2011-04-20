class ProductController < ApplicationController

  def express
    @product = 'express'
    @try_link_points_to = try_it_destination(1)
  end
  
  def flex
    @product = 'flex'
    @try_link_points_to = try_it_destination(2)
    return
  end

  def power
    @product = 'power'
    render :layout => 'application'
  end
  
  def try_it_destination(product_number)
    return 'register' unless session[:login]
    
    if session[:roles]
      return 'getting_started' if session[:roles].include? "cloud_access_#{product_number}"
      
      return 'queue' if session[:roles].include? "cloud_access_request_#{product_number}"
    end
    return 'request'

  end  
  
end
