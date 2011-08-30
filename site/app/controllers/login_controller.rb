require 'pp'

class LoginController < ApplicationController

  def show_flex    
    @register_url = user_new_flex_url
    show
  end
  
  def show_express
    @register_url = user_new_express_url
    show
  end

  def show
    remote = false
    referrer = nil
    if request.referer && request.referer != '/'
      referrer = URI.parse(request.referer)
      Rails.logger.debug "Referrer: #{referrer.to_s}"
      remote = remote_request(referrer)
      if remote
        Rails.logger.debug "Logging out user referred from: #{referrer.to_s}"
        reset_sso
      end
    end
    @register_url = @register_url ? @register_url : user_new_express_url
    if params[:redirectUrl]
      session[:login_workflow] = params[:redirectUrl]
    else
      setup_login_workflow(referrer, remote)
    end
    @redirectUrl = root_url
    @errorUrl = login_error_url
    Rails.logger.debug "Session workflow in LoginController#show: #{workflow}"
    render :show
  end

  def error
    #TODO - better error handling
    @user = WebUser.new
    @user.errors[:error] << "- Invalid username or password"
    show
  end

  def create
    Rails.logger.warn "Non integrated environment - faking login"
    session[:login] = params['login']
    session[:ticket] = "test"
    session[:user] = WebUser.new(:email_address => params['login'], :rhlogin => params['login'])
    cookies[:rh_sso] = 'test'

    Rails.logger.debug "Session workflow in LoginController#create: #{workflow}"
    Rails.logger.debug "Redirecting to home#index"    
    redirect_to root_path
  end
end
