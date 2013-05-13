class LogoutController < ApplicationController
  include LogHelper

  layout 'simple'

  def show
    @redirect = server_relative_uri(params[:then] || params[:redirectUrl] || root_path)
    @cause = params[:cause].presence

    user_action :logout, true, :login => current_user.login

    reset_sso
    reset_session
  rescue Exception => e
    logger.warn "Exception in logout: #{e}\n#{e.backtrace.join("\n  ")}"
  ensure
    case @cause
    when nil
      redirect_to @redirect if @redirect
    when 'expired'
      render :expired
    when 'change_account'
      render :change_account
    when 'server_unavailable'
      render :server_unavailable
    end
  end
end
