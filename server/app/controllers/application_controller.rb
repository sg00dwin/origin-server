class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_credentials

  def check_credentials
    rh_sso = cookies[:rh_sso]
    Rails.logger.debug "rh_sso cookie = '#{rh_sso}'"

    return unless rh_sso

    if session[:login]
      Rails.logger.debug "User has an authenticated session"
      if session[:ticket] != rh_sso
        Rails.logger.debug "Session ticket does not match current ticket - killing session"
        reset_session
      else
        Rails.logger.debug "Session ticket matches current ticket"
      end
    else
      Rails.logger.debug "User does not have a authenticated session"
      Rails.logger.debug "Looking up user based on rh_sso ticket"
      user = WebUser.find_by_ticket(rh_sso)
      Rails.logger.debug "Found #{user}. Authenticating session"
      session[:login] = user.emailAddress
      session[:ticket] = rh_sso
    end
  end
end
