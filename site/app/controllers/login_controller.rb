class LoginController < ApplicationController
  include LogHelper

  layout 'simple'

  def show
    @redirectUrl = valid_referrer(params[:then] || params[:redirectUrl] || request.referrer)
    user_params = params[:web_user] || params
    @user = WebUser.new :rhlogin => (user_params[:rhlogin] || user_params[:login] || user_params[:email_address])
    @release_note = ReleaseNote.cached.latest rescue nil
    @events = Event.cached.upcoming.first(3) rescue []
  end

  def create
    @redirectUrl = valid_referrer(params[:then] || params[:redirectUrl])
    user_params = params[:web_user] || params

    @user = WebUser.new
    if @user.authenticate(user_params[:rhlogin] || user_params[:login], user_params[:password])

      self.current_user = @user

      if validate_user
        logger.debug "  Authenticated with user #{@user.login}, redirecting"

        user_action :login, true, :login => @user.login
        redirect_to after_login_redirect
      end

    else
      logger.debug "  Authentication failed"
      @release_note = ReleaseNote.cached.latest rescue nil
      @events = Event.cached.upcoming.first(3) rescue []
      user_action :login, false, :login => @user.login
      render :show
    end
  end

  protected
    def after_login_redirect
      @redirectUrl || default_after_login_redirect
    end

    def valid_referrer(referrer)
      referrer = (URI.parse(referrer) rescue nil) if referrer.is_a? String
      case
      when referrer.nil?, remote_request?(referrer)
        nil
      when [
        login_path,
        reset_account_password_path,
        new_account_password_path,
        new_account_path,
        complete_account_path,
      ].any? {|path| referrer.path.starts_with?(path) }
        nil
      when !referrer.path.start_with?('/')
        nil
      else
        referrer.to_s
      end
    end

end
