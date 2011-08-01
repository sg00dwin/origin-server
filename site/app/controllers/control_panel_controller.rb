class ControlPanelController < ApplicationController
  before_filter :require_login

  def index
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login], 
				    :ticket => session[:ticket]
    @userinfo.establish unless @userinfo.nil?
    Rails.logger.debug "In cp controller. userinfo: #{@userinfo.inspect}"
    if @userinfo.namespace.blank?
      @domain = ExpressDomain.new
      @action = 'create'
      Rails.logger.debug 'No domain yet, show create form'
    else
      @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin,
				  :namespace => @userinfo.namespace,
				  :ssh => @userinfo.ssh_key
      @action = 'update'
      Rails.logger.debug 'Has a domain - show edit form'
    end
  end

end
