class ControlPanelController < ApplicationController
  before_filter :require_login

  @@exclude_carts = ['raw-0.1', 'jenkins-1.4']

  def index
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
    				    :ticket => session[:ticket]
    # We have to have userinfo for the control panel to work
    # so if we can't establish the user's info, try again
    3.times do
      Rails.logger.debug 'Trying to establish'
      @userinfo.establish
      Rails.logger.debug 'Errors'
      Rails.logger.debug @userinfo.errors.inspect
      Rails.logger.debug @userinfo.errors.length 
      break if @userinfo.errors.length < 1
    end
    
    # If we really can't establish, at least let the user
    # know, so it's somewhat less confusing
    # unless @userinfo.errors.length < 1 
      # flash[:error] = @userinfo.errors[:base][0]
      # render :no_info and return
    # end
      
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
    end
      
    # create app
    @max_apps = Rails.configuration.express_max_apps
    @app = ExpressApp.new
    @cartlist = ( ExpressCartlist.new 'standalone' ).list
    @cartlist -= @@exclude_carts
    Rails.logger.debug "Control panel cartlist: #{@cartlist.inspect}"
  end # end index
end # end class

