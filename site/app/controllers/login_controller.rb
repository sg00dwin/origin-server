require 'pp'
require 'net/http'
require 'net/https'
require 'uri'

class LoginController < SiteController

  before_filter :new_forms, :only => [:show]
  before_filter :protect_remote, :only => :show

  def protect_remote
    if request.referer && request.referer != '/'
      referrer = URI.parse(request.referer)
      Rails.logger.debug "Referrer: #{referrer.to_s}"
      remote_request = remote_request?(referrer)
      if remote_request
        Rails.logger.debug "Logging out user referred from: #{referrer.to_s}"
        reset_sso
      else
        @localReferrer = referrer
      end
    end
  end

  def show
    @redirectUrl = params[:redirectUrl] || @localReferrer

    # The login page should ensure the rh_sso cookie is empty
    cookies.delete :rh_sso, :domain => cookie_domain if cookies[:rh_sso]

    render :show, :layout => 'simple'
  end

  def create
    @redirectUrl = params[:redirectUrl] || console_path

    @user = WebUser.new
    if @user.authenticate(params['login'], params['password'])
      session[:login] = @user.rhlogin
      session[:ticket] = @user.ticket
      session[:user] = @user
      cookies[:rh_sso] = domain_cookie_opts(:value => @user.ticket)
      set_previous_login_detection
      redirect_to @redirectUrl
    else
      render :show, :layout => 'simple'
    end
  end

  # Helper to apply common defaults to cookie options
  def domain_cookie_opts(opts)
    defaults = {
      :secure => true,
      :path => '/',
      :domain => cookie_domain
    }
    defaults.merge(opts)
  end
  
end
