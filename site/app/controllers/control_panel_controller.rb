class ControlPanelController < ApplicationController
  before_filter :require_login, :require_user

  @@exclude_carts = ['raw-0.1', 'jenkins-1.4']

  def index
      
    Rails.logger.debug "In cp controller. userinfo: #{@userinfo.inspect}"
    
    # domain
    if @userinfo.namespace.blank?
      @domain = ExpressDomain.new
      @action = 'create'
      Rails.logger.debug 'No domain yet, show create form'
    else
      @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin,
				  :namespace => @userinfo.namespace,
				  :ssh => @userinfo.readable_ssh_key
      @action = 'update'
      Rails.logger.debug 'Has a domain - show edit form'
    end
      
    # create app
    @max_apps = Rails.configuration.express_max_apps
    @app = ExpressApp.new
    @cartlist = ( ExpressCartlist.new 'standalone' ).list
    @cartlist -= @@exclude_carts
    Rails.logger.debug "Control panel cartlist: #{@cartlist.inspect}"
  end # end index
end # end class

