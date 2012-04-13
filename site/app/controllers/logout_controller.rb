class LogoutController < SiteController
  def show
    redirect = params[:then] || params[:redirectUrl] || root_path

    reset_sso
    reset_session

    redirect_to redirect
  end
end
