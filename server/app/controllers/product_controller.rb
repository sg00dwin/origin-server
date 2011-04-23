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
  
  
end
