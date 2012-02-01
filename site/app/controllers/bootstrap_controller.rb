class BootstrapController < ApplicationController
  def index
    render :index, :layout => 'bootstrap'
  end  
end
