class ProductController < ApplicationController

  def express
    @product = 'express'
  end
  
  def flex
    @product = 'flex'
    return
  end

  def power
    @product = 'power'
    render :layout => 'application'
  end
  
end
