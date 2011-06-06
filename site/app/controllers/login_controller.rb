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
    referrer = URI.parse(request.referer)
    remote_request = referrer.host && request.host != referrer.host
    if remote_request
      Rails.logger.debug "Logging out user referred from: #{request.referer}"
      reset_sso
    end
    @register_url = @register_url ? @register_url : user_new_express_url
    if params[:redirectUrl]
      session[:login_workflow] = params[:redirectUrl]
    end
    if !workflow && request.referer != '/'
      if remote_request
        @redirectUrl = request.referer
      else
        if request.protocol == 'http://'
          session[:login_workflow] = 'https://' + request.url[request.protocol.length, request.url.length]                 
        else
          session[:login_workflow] = request.referer
        end
      end
    else
      @redirectUrl = root_url
    end
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
    session[:user] = WebUser.new(:email_address => params['login'])
    cookies[:rh_sso] = 'test'

    Rails.logger.debug "Session workflow in LoginController#create: #{workflow}"
    Rails.logger.debug "Redirecting to home#index"    
    redirect_to root_path
  end
end
