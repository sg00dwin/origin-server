class ApplicationController < ActionController::Base
  include Secured
  include AsyncAware

  protect_from_forgery

  rescue_from AccessDeniedException do |e|
    logger.debug "Access denied: #{e}"
    redirect_to logout_path :cause => e.message, :then => account_path
  end

  def handle_unverified_request
    raise AccessDeniedException, "Request authenticity token does not match session #{session.inspect}"
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def terms_redirect
    redirect = session[:terms_redirect]
    session[:terms_redirect] = nil
    redirect || default_after_login_redirect
  end

  def terms_redirect=(redirect)
    session[:terms_redirect] = redirect
  end

  def remote_request?(referrer)
    referrer.present? && referrer.host && (
      (request.host != referrer.host) || !referrer.path.start_with?('/app')
    )
  end

  def server_relative_uri(s)
    return nil unless s.present?
    uri = URI.parse(s).normalize
    #uri.path = nil if uri.path == '/'
    uri.query = nil if uri.query == '?'
    return nil unless uri.path.present? || uri.query.present?
    URI::Generic.build([nil, nil, nil, nil, nil, uri.path, nil, uri.query.presence, nil]).to_s
  rescue
    nil
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

  def upgrade_in_rails_31
    raise "Code needs upgrade for rails 3.1+" if Rails.version[0..3] != '3.0.'
  end
end
