module Account
  module ExternalCreation
    extend ActiveSupport::Concern

    require_dependency 'json'

    def create_external
      logger.debug "External registration request"

      data = JSON.parse(params[:json_data])

      @user = WebUser.new(data)

      registration_referrer = params[:registration_referrer]
      if !registration_referrer
        json = JSON.generate({:errors => {:registration_referrer => ['registration_referrer not provided']}})
        render :json => json, :status => :bad_request and return
      end

      # Run validations
      if !@user.valid?
        json = JSON.generate({:errors => create_json_error_hash(@user.errors)})
        render :json => json, :status => :bad_request and return
      end

      if params[:captcha_secret] != Rails.configuration.captcha_secret
        render :nothing => true, :status => :unauthorized and return
      end

      begin
        confirmationUrl = url_for(:action => 'confirm_external',
                                  :controller => 'email_confirm',
                                  :only_path => false,
                                  :registration_referrer => registration_referrer,
                                  :protocol => 'https')
        @user.register(confirmationUrl)
      rescue Exception => e
        json = JSON.generate({:errors => {:base => [e.message]}})
        render :json => json, :status => :internal_server_error and return
      end

      if @user.errors.length == 0
        json = JSON.generate({:result => "Check your inbox for an email with a validation link. Click on the link to complete the registration process."})
        render :json => json and return
      else
        json = JSON.generate({:errors => create_json_error_hash(@user.errors)})
        render :json => json, :status => :internal_server_error and return
      end
    end

    protected
      def create_json_error_hash(user_errors)
        errors = {}
        user_errors.keys.each do |key|
          errors[key] = user_errors[key]
        end
        errors
      end

  end
end
