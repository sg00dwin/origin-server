require 'net/http'
require 'net/https'
require 'json'
require 'cgi'

class EmailConfirmController < SiteController

  layout 'simple'

  def confirm_external
    registration_referrer = params[:registration_referrer]
    if registration_referrer
      path = url_for(:action => 'show',
                     :controller => 'getting_started_external',
                     :only_path => true,
                     :registration_referrer => registration_referrer)
      confirm(path)
    else
      confirm
    end
  end

  def confirm(redirect_path=nil)
    key = params[:key]
    email = params[:emailAddress]

    @user = WebUser.new

    if key.blank? or email.blank?
      @user.errors.add(:base, 'The confirmation link is not correct.  Please check that you copied the link correctly or try registering again.')

    elsif @user.confirm_email(key, email)
      redirect_path ||= server_relative_uri(params[:then]) || default_after_signup_redirect

      self.current_user = @user

      redirect_to redirect_path and return
    end

    logger.debug "  Errors during confirmation #{@user.errors.inspect}"
    render :error
  end
end
