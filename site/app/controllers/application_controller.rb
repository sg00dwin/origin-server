class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_credentials

  rescue_from AccessDeniedException, :with => :redirect_to_logout
  rescue_from 'ActiveResource::ConnectionError' do |e|
    if defined? e.response and defined? env and env
      env['broker.response'] = e.response.inspect
      env['broker.response.body'] = e.response.body if defined? e.response.body
    end
    raise e
  end

  def handle_unverified_request
    super
    redirect_to_logout
  end

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
  
  def reset_sso       
    if Rails.configuration.integrated and cookies[:rh_sso]
      # If we're integrated, let's log out of SSO on behalf of the user
      uri = URI.join( Rails.configuration.streamline[:host], Rails.configuration.streamline[:logout_url] )
      https = Net::HTTP.new( uri.host, uri.port )
      Rails.logger.debug "Integrated logout, use SSL"
      https.use_ssl = true
      # TODO: Need to figure out where CAs are so we can do something like:
      #   http://goo.gl/QLFFC
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Make the request
      req = Net::HTTP::Get.new( uri.path )
      req['Cookie'] = "rh_sso=#{cookies[:rh_sso]}"

      # Create the request
      # Add timing code
      start_time = Time.now
      res = https.start{ |http| http.request(req) }
      end_time = Time.now
      Rails.logger.debug "Response from Streamline took (#{uri.path}): #{(end_time - start_time)*1000} ms"
      Rails.logger.debug "Status received: #{res.code}"
      Rails.logger.debug "-------------------"
      Rails.logger.debug res.header.to_yaml
      Rails.logger.debug "-------------------"

      unless 302 == res.code.to_i
        Rails.logger.debug "Unexpected HTTP status from logout: #{res.code}"
      end
    end
    Rails.logger.debug "Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
    cookies.delete :rh_sso, :domain => cookie_domain
  end
  
  # The domain that the user's cookie should be stored under
  def cookie_domain
    domain = Rails.configuration.streamline[:cookie_domain] || 'redhat.com'
    domain = request.host if :current == domain
    return nil if domain == :nil
    domain = ".#{domain}" unless domain[0..0] == '.'
    domain
  end

  def redirect_to_logout
    redirect_to logout_path and return
  end
  
  def setup_login_workflow(referrer, remote_request)
    unless workflow
      if referrer 
        if remote_request
          session[:login_workflow] = referrer.to_s
        else
          if referrer.path =~ /^\/app\/user\/?/
            if referrer.path =~ /^\/app\/user\/new\/flex\/?/
              session[:login_workflow] = flex_path
            elsif referrer.path =~ /^\/app\/user\/new\/express\/?/
              session[:login_workflow] = express_path
            end
          elsif referrer.path =~ /^\/app\/login\/?/
            if referrer.path =~ /^\/app\/login\/flex\/?/
              session[:login_workflow] = flex_path
            elsif referrer.path =~ /^\/app\/login\/express\/?/
              session[:login_workflow] = express_path
            end
          elsif !(referrer.path =~ /^\/app\/?$/)
            if referrer.scheme == 'http'
              session[:login_workflow] = 'https' + referrer.to_s[referrer.scheme.length..-1]
            else
              session[:login_workflow] = referrer.to_s
            end
          end
        end
      end
      unless workflow
        session[:login_workflow] = default_logged_in_redirect
      end
    end
  end
  
  def default_logged_in_redirect
    @default_login_workflow || console_path
  end

  def remote_request?(referrer)
    return referrer.host && ((request.host != referrer.host) || !referrer.path.start_with?('/app'))
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
        ensure_valid_ticket
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
          session[:ticket_verified] = Time.now.to_i
        end

        # Handle access requests
        request_access(user)
      end
    end
  end

  def ensure_valid_ticket
    # don't re-verify logout requests
    return if request.path =~ /logout/

    reverify_interval = Rails.configuration.sso_verify_interval

    if session[:login] && reverify_interval > 0
      ts = session[:ticket_verified] || 0
      diff = Time.now.to_i - ts

      if (diff > reverify_interval)
        Rails.logger.debug "ticket_verified timestamp has expired, checking ticket: #{session[:ticket]}"

        user = WebUser.find_by_ticket(session[:ticket])
        if !user || session[:login] != user.rhlogin
          Rails.logger.debug "SSO ticket no longer valid, logging out!"
          redirect_to_logout
        end

        # ticket is valid, set a new timestamp
        session[:ticket_verified] = Time.now.to_i
      end
    end
  end

  # Detect previous login
  def previously_logged_in?
    cookies[:prev_login] ? true : false
  end

  private

  def new_forms
    @new_forms_enabled = true
  end
  def new_forms?
    @new_forms_enabled
  end

  def require_login
    Rails.logger.debug 'Login required'
    if !session[:login]
      Rails.logger.debug "Session contents: #{session.inspect}"
      session[:login_workflow] = url_for :controller => self.controller_name, 
                                         :action => self.action_name
      redirect_to login_path
    end
  end

  def require_user
    Rails.logger.debug 'User required'

    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
    				    :ticket => session[:ticket]
    # We have to have userinfo for the control panel to work
    # so if we can't establish the user's info, try again
    3.times do
      Rails.logger.debug 'Trying to establish'
      @userinfo.establish
      Rails.logger.debug 'Errors'
      Rails.logger.debug @userinfo.errors.inspect
      Rails.logger.debug @userinfo.errors.length 
      break if @userinfo.errors.length < 1
    end
  
    # If we really can't establish, at least let the user
    # know, so it's somewhat less confusing
    if @userinfo.errors.length > 0
      err = @userinfo.errors[:base][0]

      # only show the page if it's an "unknown" error
      # TODO: use something other than string comparison to detect
      if err == I18n.t(:unknown)
        flash[:error] = err
        render :no_info and return
      end
    end
  end
  
  # Block all access to a controller
  def deny_access
    Rails.logger.debug 'Access denied to this controller'
    redirect_to root_path
  end
  
  def sauce_testing?
    retval = false
    if Rails.env.development?
      Rails.logger.debug "------"
      Rails.logger.debug "Checking for Sauce testing credentials"
      Rails.logger.debug request.cookies.to_yaml

      key = 'sauce_testing'
      Rails.logger.debug "cookie: #{request.cookies[key]}"
      retval = true if (request.cookies[key] == 'true')

      Rails.logger.debug "------"
    end

    Rails.logger.debug "========== TESTING ===========" if retval
    retval
  end
end
