# We need this to ensure that the lib is properly reloaded
require_dependency 'captcha_helper'

module Account
  module Creation
    extend ActiveSupport::Concern

    # This mixin allows us to define multiple Captcha types
    include CaptchaHelper
    include Console::LogHelper

    included do
      before_filter :set_captcha_vars
      before_filter :validate_captcha_type, :only => [:new,:create]
    end

    def new
      @redirect = params[:then] || params[:redirect].presence || params[:redirectUrl].presence

      @user = WebUser.new params[:web_user]
    end

    def create
      logger.debug "Registration request"

      @redirect = server_relative_uri(params[:then])
      @user = WebUser.new params[:web_user]

      # Run validations
      valid = @user.valid?

      logger.debug "Starting user creation: #{@user.email_address}"

      # See if the captcha secret was provided
      if skip_captcha?
        logger.debug "Captcha secret provided - ignoring captcha"
      else
        # Remove the captcha_secret since it was wrong
        @captcha_secret = nil
        if sauce_testing? #Checks for sauce_testing cookie and development Rails
          logger.debug "Sauce testing cookie provided - ignoring captcha"
        else
          logger.debug "Checking captcha"
          # Verify the captcha
          unless (valid = valid?({:request => request, :params => params}))
            logger.debug "Captcha check failed"
            @captcha_status = "Failed"
            @user.errors[:captcha] = "Incorrect captcha submitted"

            user_action :captcha, false, :email => @user.email_address
          else
            logger.debug "Captcha check passed"
          end
        end
      end

      # Verify product choice if any
      @product = 'openshift'
      action = 'confirm'

      # Stop if you have a validation error
      unless valid
        respond_to do |format|
          format.js { render :json => @user.errors and return }
          format.html { render 'new', :layout => 'simple' and return }
        end
      end

      confirmationUrl = url_for(:action => 'confirm',
                                :controller => 'email_confirm',
                                :only_path => false,
                                :protocol => 'https',
                                :then => @redirect)

      @user.register(confirmationUrl, @user.promo_code)

      logger.debug "Confirmation URL: #{confirmationUrl}"

      unless @user.errors.empty?
        user_action :create_user, false, :email => @user.email_address, :confirmation_code => @user.token

        render :new and return
      end

      # Successful user registration event for analytics
      @event = 'event29'

      #Process promo code
      if @user.promo_code and not @user.promo_code.blank?
        PromoCodeMailer.promo_code_email(@user).deliver rescue log_error($!, "Unable to send promo code")
      end

      # Store these in session so we can use it in the redirected method
      session[:captcha_status] = "Passed"
      session[:captcha_type]   = @captcha_type

      # Log the successful user creation
      user_action :create_user, true, :email => @user.email_address, :confirmation_code => @user.token, :promo_code => @user.promo_code.presence, :source => params[:source].presence

      redirect_to complete_account_path(:promo_code => @user.promo_code.presence)
    end

    def complete
      @event = 'event29' # set omniture 'simple registration' event

      if params[:promo_code]
        @event += ",event8"
        @evar8 = params[:promo_code]
      end

      @google_conversion_label = "3qfsCMjw0gIQqKqa4AM"

      render :create
    end

    def welcome
      redirect_to getting_started_path
    end

    private
    def set_captcha_vars
      # Handle everything we need here so we don't need params in the module
      @captcha_secret  = params[:captcha_secret]
      @captcha_type    = session[:captcha_type] || params[:captcha_type] || CaptchaHelper.random_captcha
      @captcha_status  = session[:captcha_status] || params[:captcha_status] || "Viewed"

      session[:captcha_type] = nil
      session[:captcha_status] = nil
    end

    def validate_captcha_type
      unless CaptchaHelper.available_captchas.has_key?(@captcha_type.to_sym)
        params.delete(:captcha_type)
        redirect_to new_account_path(params)
      end
    end
  end
end
