class LogoutController < AccountController
  layout 'simple'

  def show
    @redirect = server_relative_uri(params[:then] || params[:redirectUrl] || root_path)
    @cause = params[:cause].presence

    reset_sso
    reset_session
  rescue Exception => e
    logger.warn "Exception in logout: #{e}\n#{e.backtrace.join("\n  ")}"
  ensure
    redirect_to @redirect if @cause.blank?
  end
end
