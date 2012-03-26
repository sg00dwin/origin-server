class PasswordController < ApplicationController
  layout 'simple'

  before_filter :require_login, :only => [:edit, :update]
  before_filter :new_forms

  def new
    user_params = params[:web_user] || params
    @user = WebUser.new(:email_address => user_params[:email_address])
  end

  # This function makes the first request to send an email with a token
  def create
    @user = WebUser.new(:email_address => params[:web_user][:email_address])

    if @user.request_password_reset(reset_password_url)
      redirect_to success_password_path
    else
      render :action => :new
    end
  end

  def success
  end

  def show
    redirect_to logged_in? ? edit_password_path : new_password_path
  end

  def reset
    token = params[:token]
    @user = WebUser.new({:email_address => params[:email]})

    if token.blank? or @user.email_address.blank?
      @user.errors.add(:base, 'The reset password link is not correct.  Please check that you copied the link correctly or try resetting your password again.')
      render :reset_error
    elsif not @user.complete_reset_password(token)
      render :reset_error
    else
      reset_sso
      reset_session
    end

  rescue Streamline::TokenExpired
    render :reset_expired
  end

  def edit_with_token
    @user = WebUser.new :email_address => params[:email]
    @token ||= params[:token] #when reset is integrated
    render :action => :edit, :layout => 'console'
  end

  def edit
    @user ||= session_user ||= WebUser.new
    @token ||= params[:token] #when reset is integrated
    render :layout => 'console'
  end

  def update
    @user = session_user
    user_params = params[:web_user]
    ['old_password', 'password', 'password_confirmation'].each do |name|
      @user.send("#{name}=", user_params[name])
    end

    respond_to do |format|
      if @user.change_password
        format.html { redirect_to account_path }
        format.js { render :json => { :status => 'success', :message => 'Your password has been successfully changed' } }
      else
        msg = @user.errors.values.first
        format.html { render :action => :edit, :layout => 'console' }
        format.js { render :json => { :status => 'error', :message => msg } }
      end
    end
  end

end
