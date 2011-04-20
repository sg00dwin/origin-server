class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_credentials
  
  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def setup_user_session(user)
    session[:login] = user.rhlogin
    session[:user] = user
  end
  
  def session_user
    user = session[:user]
    if user
      user.errors.clear      
    end
    return user
  end

  def check_credentials
    # If this is a logout request, pass through
    Rails.logger.debug "Checking for logout request"
    return if request.path =~ /logout/

    Rails.logger.debug "Not a logout request, checking for cookie"
    rh_sso = cookies[:rh_sso]
    Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"

    # TODO - what if you don't have the cookie, but have session?
    return unless rh_sso

    if session[:login]
      Rails.logger.debug "User has an authenticated session"
      if session[:ticket] != rh_sso
        Rails.logger.debug "Session ticket does not match current ticket - logging out"
        redirect_to logout_path and return
      else
        Rails.logger.debug "Session ticket matches current ticket"
      end
    else
      Rails.logger.debug "User does not have a authenticated session"
      Rails.logger.debug "Looking up user based on rh_sso ticket"
      user = WebUser.find_by_ticket(rh_sso)
      if user
        Rails.logger.debug "Found #{user}. Authenticating session"
        setup_user_session(user)
        session[:ticket] = rh_sso
      end
    end
  end
end
