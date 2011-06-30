class ApplicationController < ActionController::Base
  before_filter :check_credentials
  attr_accessor :ticket
  
  def check_credentials
    rh_sso = cookies[:rh_sso]
    if rh_sso
      Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"
      @ticket = rh_sso
    end
  end
end
