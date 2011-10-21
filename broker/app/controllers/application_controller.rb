class ApplicationController < ActionController::Base
  before_filter :check_credentials, :store_user_agent
  attr_accessor :ticket
  
  def check_credentials
    rh_sso = cookies[:rh_sso]
    if rh_sso
      Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"
      @ticket = rh_sso
    end
  end
  
  def store_user_agent
    user_agent = request.headers['User-Agent']
    Rails.logger.debug "User-Agent = '#{user_agent}'"
    Thread.current[:user_agent] = user_agent
  end
end
