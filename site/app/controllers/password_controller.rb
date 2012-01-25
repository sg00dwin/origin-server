class PasswordController < ApplicationController

  before_filter :require_login, :only=> [:edit, :update]

  def new
    @user ||= WebUser.new
  end

  # This function makes the first request to send an email with a token
  def create
    # Test the email against the WebUser validations
    @user = WebUser.new(params[:web_user])
    @user.valid?

    respond_to do |format|
      if @user.errors[:email_address].empty?
        if Rails.configuration.integrated
          user.request_password_reset({
            :login => @user.email_address,
            :url   => user_reset_password_url
          })
        else
          Rails.logger.warn "Non integrated environment - faking password reset"
        end
        format.html { redirect_to(password_path) }
        format.js { render :json => {
            :status => 'success',
            :message => "The information you have requested has been emailed to you at #{params[:email]}."
          }
        }
      else
        format.html { render :action => :new and return }
        format.js { render :json => {
            :status => 'error',
            :message => 'The email supplied is invalid'
          }
        }
      end
    end
  end

  def show
    
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
    @token = params[:token]
    @user = WebUser.new :email_address => params[:email]
    render :action => :edit
  end

  def edit
    @user ||= session_user ||= WebUser.new
    #@token ||= params[:token] when reset is integrated
  end

  def update
    @user = session_user
    user_params = params[:web_user]
    if user_params.nil?
      raise "No params"
    end
    Rails.logger.debug user_params.to_yaml

    if Rails.configuration.integrated
      json = @user.change_password({
        'oldPassword' => params['old_password'],
        'newPassword' => user_params['password'],
        'newPasswordConfirmation' => user_params['password_confirmation']
      })
    else
      Rails.logger.warn "Non integrated environment - faking password change"
      json = {}
      unless params[:test].nil?
        json['errors'] = [params[:test]]
      end
    end

    respond_to do |format|
      if json['errors'].present?
        msg = 'Your password could not be changed'
        field = :password
        if json['errors'].include? 'password_incorrect'
          msg = 'Your old password was incorrect'
          field = :old_password
        elsif json['errors'].include? 'password_invalid'
          msg = 'Please choose a valid new password'
        end

        format.html do 
          @user.errors.add(field, msg)
          Rails.logger.debug @user.errors.to_yaml
          render :action => :edit
        end
        format.js { render :json => { :status => 'error', :message => msg } }
      else
        format.html { redirect_to account_path }
        format.js { render :json => { :status => 'success', :message => 'Your password has been successfully changed' } }
      end
    end
  end

end
