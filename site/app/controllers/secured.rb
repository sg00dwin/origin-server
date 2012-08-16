#
# This mixin follows general Devise naming conventions assuming a user model named User.
#
module Secured
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?, :previously_signed_in?
  end

  ##
  # Methods for accessing information about the current user
  #

  #
  # Return the currently authenticated user or nil if no such user exists
  #
  def current_user
    @authenticated_user ||= user_from_session
    @authenticated_user.errors.clear if @authenticated_user #FIXME: this should be unnecessary because controllers can clean it up
    @authenticated_user
  end
  def user_signed_in?
    current_user.present?
  end

  # Legacy
  def session_user
    current_user
  end
  def logged_in?
    user_signed_in?
  end

  #
  # Return true if the user has logged in at least once to OpenShift.
  #
  def previously_signed_in?
    cookies[:prev_login] ? true : false
  end
  # Legacy
  def previously_logged_in?
    previously_signed_in?
  end


  protected
    ##
    # Methods to check authentication and session status
    #

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
          if !user || login != user.login
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
      user = current_user

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
        self.terms_redirect = after_login_redirect
        redirect_to new_terms_path
        false
      end
    end

    def current_user=(user)
      cookies.permanent[:prev_login] = true
      cookies[:rh_sso] = {
        :value => user.ticket,
        :secure => true,
        :path => '/',
        :domain => sso_cookie_domain,
      }
      user_to_session(user)
    end

    #
    # Controller before_filter to ensure that a user is properly authenticated prior to accessing
    # a controller action.
    #
    # Usage:
    #   before_filter :authenticate_user!
    #
    def authenticate_user!
      logger.debug '  Login required'
      logger.debug "  Session contents: #{session.inspect}"

      return redirect_to login_path(:redirectUrl => after_login_redirect) unless user_signed_in?

      validate_ticket
      validate_user
    end
    # Legacy
    def require_login
      authenticate_user!
    end


    ##
    # Methods to manage the Streamline single sign-on (SSO) cookie.
    #

    # Ensure that the single sign on cookie is removed
    def reset_sso
      current_user.logout if user_signed_in?
      logger.debug "  Removing current SSO cookie value of '#{cookies[:rh_sso]}'"
      cookies.delete :rh_sso, :domain => sso_cookie_domain
    end

    # The domain that the user's cookie should be stored under
    def sso_cookie_domain
      domain = Rails.configuration.streamline[:cookie_domain] || 'redhat.com'
      case domain
      when :current, :nil, nil then nil
      else (domain[0..0] == '.') ? domain : ".#{domain}"
      end
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
    # Return the login path if the user has previously_signed_in? or the
    # new account path if not.
    #
    def login_or_signup_path(path)
      if previously_signed_in?
        login_path(:then => path)
      else
        new_account_path(:then => path)
      end
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

    ##
    # Methods for serializing and deserializing a user from the session
    #

    #
    # Set a user object on the session
    #
    def user_to_session(user)
      session[:ticket] = user.ticket
      session[:login] = user.login
      session[:streamline_type] = user.streamline_type if user.respond_to?(:streamline_type)
      session[:ticket_verified] ||= Time.now.to_i
      @authenticated_user = user
    end

  private
    #
    # Retrieve a user object from the session.
    #
    def user_from_session
      if session[:login]
        WebUser.new(:login => session[:login], :ticket => session[:ticket], :streamline_type => session[:streamline_type])
      elsif cookies[:rh_sso]
        user_to_session(WebUser.find_by_ticket(cookies[:rh_sso])) rescue nil
      else
        nil
      end
    end
end
