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

  def logged_in?
    return session[:login] ||
          (session[:user] && (params[:controller] == 'terms' || params[:controller] == 'legal'))
  end
  
  def workflow_redirect    
    wf = nil
    # login_workflow is only honored if you are logged in
    if logged_in?
      wf = session[:login_workflow]
    else
      wf = session[:workflow]
    end
    # Clear out workflow even if nothing happens.  Otherwise might get pushed into a workflow on later login.
    session[:login_workflow] = nil
    session[:workflow] = nil
    if (wf)
      Rails.logger.debug "Redirecting to workflow: #{wf}"
      redirect_to wf and return true
    else
      return false
    end
  end
  
  def workflow
    return session[:workflow] || session[:login_workflow]
  end
  
  def try_it_destination(product_number)
    return 'register' unless session[:login]
    
    user = session_user
    if user
      user.refresh_roles
      return 'getting_started' if user.has_access?(product_number)
      
      return 'queue' if user.has_requested?(product_number)
    end
    return 'request'

  end

  def check_credentials
    # If this is a logout request, pass through
    Rails.logger.debug "Checking for logout request"
    return if request.path =~ /logout/

    Rails.logger.debug "Not a logout request, checking for cookie"
    rh_sso = cookies[:rh_sso]
    Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"

    if logged_in?
      redirect_to logout_path and return
    else
      return
    end unless rh_sso

    if logged_in?
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
        session[:user] = user
        user.establish_terms
        session[:ticket] = rh_sso
        if user.terms.length > 0
          redirect_to new_terms_path and return
        else
          session[:login] = user.rhlogin
        end
      end
    end
  end
end
