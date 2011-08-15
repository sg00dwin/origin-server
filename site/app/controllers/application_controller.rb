class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_credentials
  rescue_from AccessDeniedException, :with => :redirect_to_logout
  
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

  def logged_in_with_terms?
    return session[:login]
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
      redirect_to wf
      return true
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
  
  def reset_sso       
    Rails.logger.debug "Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
    cookies.delete :rh_sso, :domain => '.redhat.com'
  end
  
  def redirect_to_logout
    redirect_to logout_path and return
  end

  def request_access(user)
    # Now check for access to Express which represents access
    # to all of OpenShift now.  At this point, the user
    # has accepted all the OpenShift terms and should already
    # have access.  If the user doesn't have the cloud_access_1
    # role or the cloud_access_request_1 role, request access
    # automatically for the user
    access_type = CloudAccess::EXPRESS
    if !user.has_access?(access_type) and !user.has_requested?(access_type)
      Rails.logger.info "User #{user.rhlogin} is missing access.  Requesting access..."
      user.request_access(access_type)
      if user.errors.length > 0
        Rails.logger.error "Auto-request access for user #{user.rhlogin} failed"
      else
        Rails.logger.info "Access request successful for user #{user.rhlogin}"
        user.refresh_roles(true)
      end
    end

    unless user.has_access?(access_type)
      Rails.logger.debug "Notifying user about pending account access"
      flash[:notice] = "Note: We are still working on getting your access setup..."
    end
  end

  def check_credentials
    # If this is a logout request, pass through
    Rails.logger.debug "Checking for logout request"
    return if request.path =~ /logout/

    Rails.logger.debug "Not a logout request, checking for cookie"
    rh_sso = cookies[:rh_sso]
    Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"

    if rh_sso
      # redirect to https if they have rh_sso but are on http:// for some reason
      # Note: doesn't work because rh_sso is a secure cookie
      #if request.protocol == 'http://'
      #  redirect_to 'https://' + request.url[request.protocol.length..-1]
      #end
    else
      if logged_in?
        redirect_to_logout
        return
      elsif params[:controller] != 'login'
        # Clear out login workflow since they didn't login.  Otherwise might get pushed into a workflow on later login.
        #Rails.logger.debug "Clearing out login_workflow since user didn't actually login"
        session[:login_workflow] = nil
        return
      else
        return
      end
    end

    if logged_in?
      Rails.logger.debug "User has an authenticated session"
      if session[:ticket] != rh_sso
        Rails.logger.debug "Session ticket does not match current ticket - logging out"
        redirect_to_logout 
        return
      else
        Rails.logger.debug "Session ticket matches current ticket"

        # Handle access requests - if terms have been accepted
        request_access(session[:user]) if logged_in_with_terms?
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
          Rails.logger.debug "User #{user} has terms to accept."
          redirect_to new_terms_path and return
        else
          session[:login] = user.rhlogin
        end

        # Handle access requests
        request_access(user)
      end
    end
  end
  
  private
  
  def require_login
    if !session[:login]
      session[:login_workflow] = url_for :controller => self.controller_name, 
                                         :action => self.action_name
      redirect_to login_path
    end
  end
  
  # Block all access to a controller
  def deny_access
    redirect_to root_path
  end
  
end
