require 'pp'

class Access::ExpressController < ApplicationController

  def index
    puts "Session = #{session[:login]}"
    unless session[:login]
      @user = WebUser.new
      render :template => 'users/index'
    end
  end

  def create
    # Check whether user is logged in
    unless session[:login]
      render 'users/index'
    end

    # If not logged in, redirect to login / register

    # If logged in, request access

    @user = WebUser.new(params[:web_user])

    # TODO - Remove
    # Only applicable for the beta registration process
    @user.termsAccepted = '1'

    # Run validations
    valid = @user.valid?

    # Verify the captcha
    unless verify_recaptcha
      valid = false
      @user.errors[:captcha] = "Captcha text didn't match"
      pp @user.errors
    end unless Rails.env == "development"

    # Stop if you have a validation error
    render :index and return unless valid

    # Only register the user if in a non-development environment
    full_register unless Rails.env == "development"
  end
end
