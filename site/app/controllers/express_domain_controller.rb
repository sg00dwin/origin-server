class ExpressDomainController < ApplicationController

  def create
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update; end
  
end
