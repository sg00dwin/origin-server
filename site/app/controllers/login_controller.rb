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
    referrer_url = request.referer ? request.referer : '/'
    referrer = URI.parse(referrer_url)
    remote_request = referrer.host && request.host != referrer.host
    if remote_request
      Rails.logger.debug "Logging out user referred from: #{referrer_url}"
      reset_sso
    end
    @register_url = @register_url ? @register_url : user_new_express_url
    if params[:redirectUrl]
      session[:login_workflow] = params[:redirectUrl]
    end
    if !workflow && referrer_url != '/' && !(referrer.path =~ /^\/app\/user\/new/) && !(referrer.path =~ /^\/app\/login/)
      if remote_request
        session[:login_workflow] = referrer_url
      else
        if request.protocol == 'http://'
          session[:login_workflow] = 'https://' + request.url[request.protocol.length..-1]
        else
          session[:login_workflow] = referrer_url
        end
      end
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
