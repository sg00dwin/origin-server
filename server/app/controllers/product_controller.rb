class ProductController < ApplicationController

  def express
    @product = 'express'
    render :index
  end
  
  def flex
    @product = 'flex'
    render :index
    return
  end

  def power
    @product = 'power'
  end
end
