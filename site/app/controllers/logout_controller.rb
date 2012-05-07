class LogoutController < SiteController
  def show
    redirect = params[:then] || params[:redirectUrl] || root_path

    reset_sso
    reset_session
  rescue Exception => e
    logger.warn "Exception in logout: #{e}\n#{e.backtrace.join("\n  ")}"
  ensure
    redirect_to redirect
  end
end
