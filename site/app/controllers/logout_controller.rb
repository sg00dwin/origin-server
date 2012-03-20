class LogoutController < SiteController
  def show
    @redirectUrl = params[:redirectUrl] || root_path

    reset_sso
    reset_session

    redirect_to @redirectUrl
  end
end
