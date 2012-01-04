class ApplicationController < ActionController::Base
  before_filter :store_user_agent
  
  def store_user_agent
    user_agent = request.headers['User-Agent']
    Rails.logger.debug "User-Agent = '#{user_agent}'"
    Thread.current[:user_agent] = user_agent
  end
end
