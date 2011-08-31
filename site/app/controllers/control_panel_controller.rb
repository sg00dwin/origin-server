class ControlPanelController < ApplicationController
  before_filter :require_login

  def index
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
				    :ticket => session[:ticket]
    @userinfo.establish unless @userinfo.nil?
    Rails.logger.debug "In cp controller. userinfo: #{@userinfo.inspect}"
    
    # domain
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
      
      # create app
      if @userinfo.app_info.length < Rails.configuration.express_max_apps
        @app = ExpressApp.new
        @cartlist = ExpressCartlist.new 'standalone'
        Rails.logger.debug "Control panel cartlist: #{@cartlist.list.inspect}"
      end
    end
    
  end

end
