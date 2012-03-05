class ControlPanelController < ApplicationController
  before_filter :require_login, :require_user

  @@exclude_carts = ['diy-0.1', 'jenkins-1.4']

  def index

    Rails.logger.debug "In cp controller. userinfo: #{@userinfo.inspect}"

    ssh_key_string = @userinfo.default_ssh_key.placeholder? ? 'ssh-rsa nossh' : @userinfo.default_ssh_key.key_string

    # domain
    if @userinfo.namespace.blank?
      @domain = ExpressDomain.new :ssh => ssh_key_string
      @action = 'create'
      Rails.logger.debug 'No domain yet, show create form'
    else
      @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin,
				  :namespace => @userinfo.namespace,
				  :ssh => ssh_key_string
      @action = 'update'
      Rails.logger.debug 'Has a domain - show edit form'
    end

    # SSH keys
    @ssh_keys = @userinfo.ssh_keys

    # create app
    @max_apps = Rails.configuration.express_max_apps
    @app = ExpressApp.new
    @cartlist = ( ExpressCartlist.new 'standalone' ).list
    @cartlist -= @@exclude_carts
    Rails.logger.debug "Control panel cartlist: #{@cartlist.inspect}"
  end # end index
end # end class

