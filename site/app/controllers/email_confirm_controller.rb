require 'net/http'
require 'net/https'
require 'json'
require 'cgi'

class EmailConfirmController < SiteController

  @@ERRORS = {'user_failed_confirmation' => "Email confirmation failed",
            'user_email_failed_confirmation' => "Email confirmation failed",
            :unknown => "An unknown error has occurred"
  }

  layout 'simple'
  
  # FIXME: remove
  def confirm_flex
    confirm
  end
  
  # FIXME: remove
  def confirm_express
    confirm
  end
  
  def confirm_external
    registration_referrer = params[:registration_referrer]
    if registration_referrer
      path = url_for(:action => 'show',
                     :controller => 'getting_started_external',
                     :only_path => true,
                     :registration_referrer => registration_referrer)
      confirm(path)
    else
      confirm
    end
  end

  def confirm(redirect_path=nil)
    key = params[:key]
    email = params[:emailAddress]

    redirect_path ||= login_path(:email_address => email)

    @user = WebUser.new

    if key.blank? or email.blank?
      @user.errors.add(:base, 'The confirmation link is not correct.  Please check that you copied the link correctly or try registering again.')

    elsif @user.confirm_email(key, email) #sets errors
      reset_sso
      reset_session
      session[:confirm_flow] = true #FIXME should not be needed when user flow check is simplified
      session[:confirm_login] = email #FIXME should not be needed when user flow check is simplified
      redirect_to redirect_path and return
    end

    logger.debug "Errors during confirmation #{@user.errors}"
    render :error

    # everything after this point is old dead code
    return

    begin
      query = {:key => key, :emailAddress => email}
      url = URI.join(Rails.configuration.streamline[:host],Rails.configuration.streamline[:email_confirm_url],"?#{query.to_query}")

      req = Net::HTTP::Get.new(url.path + '?' + url.query)
      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.start {|http| http.request(req)}
      case response
      when Net::HTTPSuccess
        logger.debug "HTTP response from server is:"
        logger.debug "Response body: #{response.body}"

        begin
          result = JSON.parse(response.body)
          if (result['errors'])
            errors = result['errors']
            if errors[0] == 'user_already_registered'
              #success
            else
              errors.each { |error|
                if (@@ERRORS[error])
                  @errors[error] = @@ERRORS[error]
                else
                  @errors[:unknown] = @@ERRORS[:unknown]
                end
              }
            end
          elsif result['emailAddress']
            #success
          else
            @errors[:unknown] = @@ERRORS[:unknown]
          end
        rescue Exception => e
          logger.error e
          @errors[:unknown] = @@ERRORS[:unknown]
        end
      else
        logger.error "Problem with server. Response code was #{response.code}"
        logger.error "HTTP response from server is #{response.body}"
        @errors[:unknown] = @@ERRORS[:unknown]
      end

    rescue Exception => e
      logger.error e
      @errors[:unknown] = @@ERRORS[:unknown]
    ensure
      if (@errors.length > 0)
        render :error and return
      else
        reset_sso
        reset_session
        session[:confirm_flow] = true
        session[:confirm_login] = email
        redirect_to redirect_path
      end
    end
  end
end
