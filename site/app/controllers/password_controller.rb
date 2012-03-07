class PasswordController < ApplicationController
  layout 'console'

  before_filter :require_login, :only => [:edit, :update]
  before_filter :new_forms

  def new
    @user ||= WebUser.new
    render :layout => 'application'
  end

  # This function makes the first request to send an email with a token
  def create
    # Test the email against the WebUser validations
    @user = WebUser.new({:email_address => params[:web_user][:email_address]})

    respond_to do |format|
      if @user.request_password_reset user_reset_password_url
        format.html { redirect_to success_password_path }
        format.js { render :json => { :status => 'success', :message => "The information you have requested has been emailed to you at #{params[:email]}." } }
      else
        format.html { render :action => :new, :layout => 'application'}
        format.js { render :json => { :status => 'error', :message => 'The email supplied is invalid' } }
      end
    end
  end

  def success
    render :layout => 'application'
  end

  def show
    redirect_to logged_in? ? edit_password_path : new_password_path
  end

  # This function actually checks the token against streamline
  def reset
    Rails.logger.debug params.to_yaml

    # Keep track of response information
    @responseText = {
      :status => 'success',
      :message => "Your password has been successfully reset! Please check your email for your new password. After you log in, don't forget to reset it using the control panel."
    }

    # Test the email against the WebUser validations
    user = WebUser.new({:email_address => params[:email]})
    user.valid?

    # Return if there is a problem with the email address
    if !user.errors[:email_address].empty?
      @responseText[:status] = 'error'
      @responseText[:message] = 'The email supplied is invalid'
    elsif !Rails.configuration.integrated
      Rails.logger.warn "Non integrated environment - faking password reset"
    else
      begin
        json = user.reset_password({ 
          :login => params[:email],
          :token => params[:token]
        })
        errors = json['errors']
        Rails.logger.debug "Data returned"
        if errors && !errors.empty?
          @responseText[:status] = 'error'
          case errors.first.to_sym
          when :token_is_invalid
            @responseText[:message] = "This password reset request is no longer valid. This could be caused by the link being more than 24 hours old or it's already been used. Please try to reset your password again using the 'Sign in' form."
          when :email_service_error
            @responseText[:message] = "An unknown error has occurred, please try again"
          end
        end
        Rails.logger.debug "Data returned"
      rescue Exception => e 
        @responseText[:status] = 'error'
        @responseText[:message] = 'An unknown error occurred, please try again'
      end
    end
  end

  def edit_with_token
    @user = WebUser.new :email_address => params[:email]
    @token ||= params[:token] #when reset is integrated
    render :action => :edit
  end

  def edit
    @user ||= session_user ||= WebUser.new
    @token ||= params[:token] #when reset is integrated
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
        format.html { render :action => :edit }
        format.js { render :json => { :status => 'error', :message => msg } }
      end
    end
  end

end
