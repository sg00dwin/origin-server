class LogoutController < SiteController
  layout 'simple'

  def show
    @redirect = params[:then] || params[:redirectUrl] || root_path
    @cause = params[:cause].presence

    reset_sso
    reset_session
  rescue Exception => e
    logger.warn "Exception in logout: #{e}\n#{e.backtrace.join("\n  ")}"
  ensure
    if @cause.blank?
      redirect_to @redirect
    end
  end
end
