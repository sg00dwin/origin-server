module Account
  module Creation
    extend ActiveSupport::Concern

    require_dependency 'recaptcha'

    def skip_captcha?
      Rails.configuration.captcha_secret.nil? or params[:captcha_secret] == Rails.configuration.captcha_secret
    end

    def new
      @redirect = params[:then] || params[:redirect].presence || params[:redirectUrl].presence
      @captcha_secret = params[:captcha_secret].presence

      @user = WebUser.new params[:web_user]
    end

    def create
      logger.debug "Registration request"

      @redirect = server_relative_uri(params[:then])
      @user = WebUser.new params[:web_user]
      @captcha_secret = params[:captcha_secret]

      # Run validations
      valid = @user.valid?

      logger.warn "Starting user creation: #{@user.email_address}"

      # See if the captcha secret was provided
      if skip_captcha?
        logger.warn "Captcha secret provided - ignoring captcha"
      elsif sauce_testing? #Checks for sauce_testing cookie and development Rails
        logger.warn "Sauce testing cookie provided - ignoring captcha"
      else
        @captcha_secret = nil
        logger.debug "Checking captcha"
        # Verify the captcha
        unless verify_recaptcha
          logger.debug "Captcha check failed"
          valid = false
          flash.delete(:recaptcha_error) # prevent the default flash from recaptcha gem
          @user.errors[:captcha] = "Captcha text didn't match"
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

      # FIXME: Need to pass signin destination through confirmation link
      confirmationUrl = url_for(:action => 'confirm',
                                :controller => 'email_confirm',
                                :only_path => false,
                                :protocol => 'https',
                                :then => @redirect)

      @user.register(confirmationUrl, @user.promo_code)

      logger.debug "Confirmation URL: #{confirmationUrl}"

      unless @user.errors.length == 0
        render :new and return
      end

      # Successful user registration event for analytics
      @event = 'event29'

      #Process promo code
      if @user.promo_code and not @user.promo_code.blank?
        PromoCodeMailer.promo_code_email(@user).deliver
      end

      redirect_to complete_account_path(:promo_code => @user.promo_code.presence)
    end

    def complete
      @event = 'event29' # set omniture 'simple registration' event

      if params[:promo_code]
        @event += ",event8"
        @evar8 = params[:promo_code]
      end

      render :create
    end
  end
end
