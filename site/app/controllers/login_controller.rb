class LoginController < SiteController

  layout 'simple'

  before_filter :check_referrer, :only => :show

  def show
    @redirectUrl = params[:then] || params[:redirectUrl] || @referrerRedirect
    user_params = params[:web_user] || params
    @user = WebUser.new :rhlogin => (user_params[:rhlogin] || user_params[:email_address])
  end

  def create
    @redirectUrl = server_relative_uri(params[:then] || params[:redirectUrl])
    user_params = params[:web_user] || params

    @user = WebUser.new
    if @user.authenticate(user_params[:rhlogin], user_params[:password])

      self.current_user = @user

      if validate_user
        logger.debug "  Authenticated with ticket #{cookies[:rh_sso]}, redirecting"
        redirect_to after_login_redirect
      end

    else
      logger.debug "  Authentication failed"
      render :show
    end
  end

  protected
    def after_login_redirect
      @redirectUrl || default_after_login_redirect
    end

    def check_referrer
      if request.referer && request.referer != '/'
        referrer = URI.parse(request.referer) rescue nil
        if remote_request? referrer
          logger.debug "  Logging out user referred from: #{referrer.to_s}"
          reset_sso
        end
        @referrerRedirect = valid_referrer(referrer)
        logger.debug "  Stored referrer #{@referrerRedirect}"
      end
    end

    def valid_referrer(referrer)
      case
      when referrer.nil?
        nil
      when [
        login_path,
        reset_account_password_path,
        new_account_path,
        complete_account_path,
      ].any? {|path| referrer.path.starts_with?(path) }
        nil
      else referrer.to_s
      end
    end
end
