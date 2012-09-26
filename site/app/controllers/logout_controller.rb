class LogoutController < ApplicationController
  layout 'simple'

  def show
    @redirect = server_relative_uri(params[:then] || params[:redirectUrl] || root_path)
    @cause = params[:cause].presence

    reset_sso
    reset_session
  rescue Exception => e
    logger.warn "Exception in logout: #{e}\n#{e.backtrace.join("\n  ")}"
  ensure
    case @cause
    when nil
      redirect_to @redirect
    when 'change_account'
      render :change_account
    end
  end
end
