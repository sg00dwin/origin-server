class GettingStartedExternalController < ApplicationController
  
  before_filter :require_login
  
  def show
    registration_referrer = params[:registration_referrer]
    render registration_referrer and return
  end
  
end
