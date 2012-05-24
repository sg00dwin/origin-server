class ApplicationController < ActionController::Base
  protect_from_forgery

  #before_filter :before_session
  #after_filter :after_session

  #def before_session 
  #  key = Rails.application.config.session_options[:key]
  #  value = request.cookies[key]
    #value = Digest::SHA1.hexdigest(value)[0..7] unless value.nil?
  #  logger.debug "Rack cookie hash #{env["rack.request.cookie_hash"].inspect}"
  #  logger.debug "Session fingerprint: #{value || 'nil'} - contents #{session.inspect}"
  #end

  #def after_session
  #  logger.debug "Contents after: #{session.inspect}"
  #end

  rescue_from AccessDeniedException do |e|
    logger.debug "Access denied: #{e}"
    redirect_to logout_path :cause => e.message, :then => account_path
  end
  rescue_from 'ActiveResource::ConnectionError' do |e|
    if defined? e.response and defined? env and env
      env['broker.response'] = e.response.inspect
      env['broker.response.body'] = e.response.body if defined? e.response.body
    end
    raise e
  end
  rescue_from 'ActiveResource::ResourceNotFound' do |e|
    logger.debug "#{e}\n  #{e.backtrace.join("\n  ")}"
    upgrade_in_rails_31 # FIXME: Switch to render :status => 404
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def handle_unverified_request
    raise AccessDeniedException, "Request authenticity token does not match session #{session.inspect}"
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  #FIXME: rename to be authenticated?
  def logged_in?
    session_user.present?
  end

  def terms_redirect
    redirect = session[:terms_redirect]
    session[:terms_redirect] = nil
    redirect || default_after_login_redirect
  end
  def terms_redirect=(redirect)
    session[:terms_redirect] = redirect
  end

  def reset_sso
    session_user.logout if session_user
    logger.debug "Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
    cookies.delete :rh_sso, :domain => cookie_domain
  end

  # The domain that the user's cookie should be stored under
  def cookie_domain
    domain = Rails.configuration.streamline[:cookie_domain] || 'redhat.com'
    case domain
    when :current, :nil, nil then nil
    else (domain[0..0] == '.') ? domain : ".#{domain}"
    end
  end

  def remote_request?(referrer)
    referrer.present? && referrer.host && (
      (request.host != referrer.host) || !referrer.path.start_with?('/app')
    )
  end

  #
  # Return true if the user has logged in at least once to OpenShift.
  #
  def previously_logged_in?
    cookies[:prev_login] ? true : false
  end

  def new_forms
    true
  end
  def new_forms?
    true
  end

  #FIXME: rename to be authenticated_user to imply the model object this retrieves
  # 
  # Return the currently authenticated user or nil if no such user exists
  #
  def session_user
    @authenticated_user ||= user_from_session
    @authenticated_user.errors.clear if @authenticated_user #FIXME: this should be unnecessary because controllers can clean it up
    @authenticated_user
  end

  #
  # Verify that the rh_sso cookie matches the ticket, and that the ticket is still valid.
  # Refresh the ticket if possible, otherwise raise AccessDeniedException.
  #
  def validate_ticket
    sso_cookie = cookies[:rh_sso]
    ticket = session[:ticket]

    if sso_cookie && sso_cookie != ticket
      raise AccessDeniedException, "Session ticket #{ticket} does not match rh_sso cookie #{sso_cookie}"
    end

    login = session[:login]
    reverify_interval = Rails.configuration.sso_verify_interval

    if login && reverify_interval > 0
      ts = session[:ticket_verified] || 0
      diff = Time.now.to_i - ts

      if (diff > reverify_interval)
        logger.debug "ticket_verified timestamp has expired, checking ticket: #{session[:ticket]}"

        user = WebUser.find_by_ticket(ticket)
        if !user || login != user.rhlogin
          raise AccessDeniedException, "SSO ticket user #{user.login} does not match active session #{login}"
        end

        # ticket is valid, set a new timestamp
        session[:ticket_verified] = Time.now.to_i
      end
    end
    true
  end

  #
  # Return true if the user can access OpenShift resources.  Otherwise, the user is redirected or
  # sees an error page.  Callers should not call redirect_to or render if false is returned.
  #
  def validate_user
    user = session_user

    if session[:terms] # terms are only checked once per session
      true
    elsif user.accepted_terms?
      if user.entitled?
        session[:terms] = true
        true
      else
        if user.waiting_for_entitle?
          logger.warn "Notifying user about pending account access"
          flash[:notice] = "Note: We are still working on getting your access setup..."
          #FIXME: redirect to a page indicating that they don't have access yet
          render 'access/pending.html.haml'
        else
          logger.error "Auto-request access for user #{user.rhlogin} failed, #{user.errors}"
          #FIXME: display a page indicating to the user that an error occurred while requesting access
          render 'access/error.html.haml'
        end
        false
      end
    else
      logger.debug "Has terms to accept"
      terms_redirect = after_login_redirect
      redirect_to new_terms_path
      false
    end
  end

  #
  # Use with before_filter to ensure that a user is properly authenticated prior to accessing
  # a controller action.
  #
  def require_login
    logger.debug 'Login required'
    logger.debug "  Session contents: #{session.inspect}"

    return redirect_to login_path(:redirectUrl => after_login_redirect) unless logged_in?

    validate_ticket
    validate_user
  end

  # Block all access to a controller
  def deny_access
    logger.debug 'Access denied to this controller'
    redirect_to root_path
  end

  def sauce_testing?
    retval = false
    if Rails.env.development?
      logger.debug "------"
      logger.debug "Checking for Sauce testing credentials"
      logger.debug request.cookies.to_yaml

      key = 'sauce_testing'
      logger.debug "cookie: #{request.cookies[key]}"
      retval = true if (request.cookies[key] == 'true')

      logger.debug "------"
    end

    logger.debug "========== TESTING ===========" if retval
    retval
  end
  
  protected
    #
    # Set a user object on the session
    #
    def user_to_session(user)
      session[:ticket] = user.ticket
      session[:login] = user.rhlogin
      session[:streamline_type] = user.streamline_type
      session[:ticket_verified] ||= Time.now.to_i
      @authenticated_user = user
    end

    #
    # The URL or path that this controller should redirect to after login.
    #
    def default_after_login_redirect
      @default_login_workflow || console_path
    end

    #
    # The URL a user is taken to after signup
    #
    def default_after_signup_redirect
      console_path
    end

    #
    # Return the appropriate URL to return to after a successful login. Subclasses may
    # override to return values that are specific to their method
    #
    def after_login_redirect
      begin
        url_for :controller => self.controller_name,
          :action => self.action_name,
          :only_path => true
      rescue ActionController::RoutingError
        logger.debug "No route matches, using default console route"
        default_after_login_redirect
      end
    end

    def upgrade_in_rails_31
      raise "Code needs upgrade for rails 3.1+" if Rails.version[0..3] != '3.0.'
    end

  private
    #
    # Retrieve a user object from the session
    #
    def user_from_session
      if session[:login]
        WebUser.new(:rhlogin => session[:login], :ticket => session[:ticket], :streamline_type => session[:streamline_type])
      elsif cookies[:rh_sso]
        user_to_session(WebUser.find_by_ticket(cookies[:rh_sso])) rescue nil
      else
        nil
      end
    end
end
