require 'pp'
require 'net/http'
require 'net/https'
require 'uri'

class LoginController < SiteController

  before_filter :new_forms, :only => [:show]
  before_filter :check_referrer, :only => :show

  def check_referrer
    if request.referer && request.referer != '/'
      referrer = URI.parse(request.referer)
      if remote_request? referrer
        Rails.logger.debug "Logging out user referred from: #{referrer.to_s}"
        reset_sso
      end
      @referrerRedirect = valid_referrer(referrer)
    end
  end

  def valid_referrer(referrer)
    case
    when referrer.path.starts_with?(user_new_flex_path); flex_path
    when referrer.path.starts_with?(login_flex_path); flex_path
    when referrer.path.starts_with?(login_path); nil
    else referrer.to_s
    end
  end

  def show
    @redirectUrl = params[:redirectUrl] || @referrerRedirect

    # The login page should ensure the rh_sso cookie is empty
    cookies.delete :rh_sso, :domain => cookie_domain if cookies[:rh_sso]

    render :show, :layout => 'simple'
  end

  def create
    @redirectUrl = params[:redirectUrl] || default_logged_in_redirect

    @user = WebUser.new
    if @user.authenticate(params['login'], params['password'])
      session[:login] = @user.rhlogin
      session[:ticket] = @user.ticket
      session[:user] = @user
      session[:ticket_verified] = Time.now.to_i

      set_previous_login_detection
      cookies['rh_sso'] = domain_cookie_opts(:value => @user.ticket)

      Rails.logger.debug "Authenticated with cookie #{cookies[:rh_sso]} redirecting to #{@redirectUrl}"
      redirect_to @redirectUrl
    else
      Rails.logger.debug "Authentication failed"
      render :show, :layout => 'simple'
    end
  end

  # Helper to apply common defaults to cookie options
  def domain_cookie_opts(opts)
    {
      :secure => true,
      :path => '/',
      :domain => cookie_domain
    }.merge!(opts)
  end

  # Set previous log in detection cookie
  def set_previous_login_detection
    cookies.permanent[:prev_login] = true
  end

end
