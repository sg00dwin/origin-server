#
# This mixin follows general Devise naming conventions assuming a user model named User.
#
module Secured
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?, :previously_signed_in?
    rescue_from ActiveResource::UnauthorizedAccess, :with => :api_rejected_authentication
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
    # Return true if the user can access OpenShift resources.  Otherwise, the user is redirected or
    # sees an error page.  Callers should not call redirect_to or render if false is returned.
    #
    def validate_user
      user = current_user

      if session[:terms] # terms are only checked once per session
        if user.api_ticket
          true
        else
          auth = begin
                   Authorization.create({
                    :scope => 'session',
                    :note => "OpenShift Console (from #{request.remote_ip} on #{user_browser})",
                    :reuse => true,
                    :as => user
                  })
                 rescue => e
                   logger.error "Unable to create an authorization: #{e.message} (#{e.class})\n  #{e.backtrace.join("\n  ")}"
                   Authorization.new.tap{ |a| 
                     a.errors[:base] = e.message 
                     a.attributes[:server_unavailable] = e.is_a?(RestApi::ServerUnavailable)
                   }
                 end
          if auth.persisted?
            logger.debug "Authorization succeeded for #{user.login}, expires in #{distance_of_time_in_words(auth.expires_at, Time.now)}"
            user.api_ticket = auth.token
            user_to_session(user)
            true
          else
            logger.debug "Authorization failed for #{user.login}, #{auth.errors.full_messages.join(', ')}"
            redirect_to logout_path(
              :cause => auth.attributes[:server_unavailable] ? :server_unavailable : :expired,
              :then => url_for({:only_path => true}.merge(params))
            )
            false
          end
        end
      elsif user.accepted_terms?
        if user.entitled?
          session[:terms] = true
          true
        else
          if user.waiting_for_entitle?
            logger.warn "Notifying user about pending account access"
            #flash[:notice] = "We are still working on getting your access setup..."
            #FIXME: redirect to a page indicating that they don't have access yet
            render 'access/pending'
          else
            logger.error "Auto-request access for user #{user.rhlogin} failed, #{user.errors}"
            #FIXME: display a page indicating to the user that an error occurred while requesting access
            render 'access/error'
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

    #
    # Update the session with a logged in user.  Will reset
    # the session to prevent fixation attacks.
    #
    def current_user=(user)
      reset_session
      cookies.permanent[:prev_login] = true
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
      logger.debug "Session contents: #{session.inspect}"

      return redirect_to login_path(:redirectUrl => after_login_redirect) unless user_signed_in?

      validate_user
    end
    # Legacy
    def require_login
      authenticate_user!
    end

    #
    # Controller before_filter to force a logout if the user is authenticated
    #
    def changing_current_user!
      if user_signed_in?
        redirect_to logout_path(
          :cause => :change_account,
          :then => url_for({:only_path => true}.merge(params))
        )
      end
    end

    def api_rejected_authentication
      redirect_to logout_path(
        :cause => :expired,
        :then => url_for({:only_path => true}.merge(params))
      )
    end

    ##
    # Methods to manage the Streamline single sign-on (SSO) cookie.
    #

    # Ensure that the user is logged out
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
      welcome_account_path
    end

    #
    # Return the appropriate URL to return to after a successful login. Subclasses may
    # override to return values that are specific to their method
    #
    def after_login_redirect
      request.fullpath || default_after_login_redirect
    end

    ##
    # Methods for serializing and deserializing a user from the session
    #

    #
    # Set a user object on the session
    #
    def user_to_session(user)
      session[:currency_cd] = nil
      session[:ticket] = user.ticket
      session[:api_ticket] = user.api_ticket
      session[:login] = user.login
      session[:streamline_type] = user.streamline_type if user.respond_to?(:streamline_type)
      @authenticated_user = user
    end

    #
    # Notify the controller that the user has been altered and should be created from
    # cache
    #
    def current_user_changed!
      user_to_session(current_user)
    end

  private
    #
    # Retrieve a user object from the session.
    #
    def user_from_session
      if session[:login]
        WebUser.new(
          :login => session[:login],
          :ticket => session[:ticket],
          :api_ticket => session[:api_ticket],
          :streamline_type => session[:streamline_type],
        )
      else
        nil
      end
    end

    def user_browser
      agent = (request.user_agent || "").downcase
      case agent
      when /safari/
          case agent
          when /mobile/
            'Safari Mobile'
          else
            'Safari'
          end
      when /firefox/
        'Firefox'
      when /opera/
        'Opera'
      when /MSIE/
        'Internet Explorer'
      else
        'browser'
      end
    end
end
