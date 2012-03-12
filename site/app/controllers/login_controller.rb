require 'pp'
require 'net/http'
require 'net/https'
require 'uri'

class LoginController < ApplicationController

  layout 'site'

  before_filter :new_forms, :only => [:show]

  def show_flex
    @register_url = user_new_flex_url
    @default_login_workflow = flex_path
    show
  end
  
  def show_express
    @register_url = user_new_express_url
    @default_login_workflow = express_path
    show
  end

  def show
    if logged_in?
      redirect_to default_logged_in_redirect and return
    end

    remote_request = false
    referrer = nil
    if request.referer && request.referer != '/'
      referrer = URI.parse(request.referer)
      Rails.logger.debug "Referrer: #{referrer.to_s}"
      remote_request = remote_request?(referrer)
      if remote_request
        Rails.logger.debug "Logging out user referred from: #{referrer.to_s}"
        reset_sso
      end
    end
    @register_url = @register_url ? @register_url : user_new_express_url
    if params[:redirectUrl]
      session[:login_workflow] = params[:redirectUrl]
    else
      setup_login_workflow(referrer, remote_request)
    end
    @redirectUrl = root_url
    @errorUrl = login_error_url
    Rails.logger.debug "Session workflow in LoginController#show: #{workflow}"
    render :show, :layout => 'box'
  end

  def error
    #TODO - better error handling
    @user = WebUser.new
    @user.errors[:error] << "- Invalid username or password"
    show
  end

  def create
    Rails.logger.warn "Non integrated environment - faking login"
    session[:login] = params['login']
    session[:ticket] = "test"
    session[:user] = WebUser.new(:email_address => params['login'], :rhlogin => params['login'])
    cookies[:rh_sso] = domain_cookie_opts(:value => 'test')

    Rails.logger.debug "Session workflow in LoginController#create: #{workflow}"
    Rails.logger.debug "Redirecting to home#index"
    redirect_to params['redirectUrl']
  end

  def ajax
    referrer = URI.parse(request.referer)
    setup_login_workflow(referrer,false)

    # Keep track of response information
    responseText = {}

    unless Rails.configuration.integrated
      Rails.logger.warn "Non integrated environment - faking login"
      session[:login] = params['login']
      session[:ticket] = "test"
      session[:user] = WebUser.new(:email_address => params['login'], :rhlogin => params['login'])
      cookies[:rh_sso] = domain_cookie_opts(:value => 'test')
      @message = 'Welcome back to OpenShift!'
      @message_type = 'success'
      set_previous_login_detection

      # Added options to make sure non-integrated environment works
      responseText[:status] = 200
      responseText[:redirectUrl] = root_url
    else
      # Do the remote login
      uri = URI.join( Rails.configuration.streamline[:host], Rails.configuration.streamline[:login_url])
      
      # Create the HTTPS object
      https = Net::HTTP.new( uri.host, uri.port )
      Rails.logger.debug "Integrated login, use SSL"
      https.use_ssl = true
      # TODO: Need to figure out where CAs are so we can do something like:
      #   http://goo.gl/QLFFC
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
      # Make the request
      req = Net::HTTP::Post.new( uri.path )
      req.set_form_data({:login => params[:login], :password => params[:password]})
  
      # Create the request
      # Add timing code
      start_time = Time.now
      res = https.start{ |http| http.request(req) }
      responseText[:status] = res.code
      end_time = Time.now
      Rails.logger.debug "Response from Streamline took (#{uri.path}): #{(end_time - start_time)*1000} ms"
  
      Rails.logger.debug "Status received: #{res.code}"
      Rails.logger.debug "-------------------"
      Rails.logger.debug res.header.to_yaml
      Rails.logger.debug "-------------------"

  
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # Decode the JSON response
          json = ActiveSupport::JSON::decode(res.body)
  
          # Set cookie and session information
          Rails.logger.debug "Cookies sent: #{YAML.dump res.header['set-cookie']}"
          cookie = res.header['set-cookie']
          if cookie
            @message_type = 'success'
            @message = 'Welcome back to OpenShift!'
            rh_sso = cookie.split('; ')[0].split('=')[1]
            cookies[:rh_sso] = domain_cookie_opts(:value => rh_sso)
            session[:ticket] = rh_sso
            responseText[:redirectUrl] = root_url
            set_previous_login_detection
          else 
            Rails.logger.debug "Unknown error (no cookie sent): #{res.code}"
            responseText[:error] = 'An unknown error occurred'
          end 
        when Net::HTTPUnauthorized
          Rails.logger.debug 'Unauthorized'
          responseText[:error] = 'Invalid username or password'
        else
          Rails.logger.debug "Unknown error: #{res.code}"
          responseText[:error] = 'An unknown error occurred'
        end
    end

    respond_to do |format|
      format.html do
        # Fallback for those without js
        flash[@message_type] = @message
        if @message_type == 'success'
          redirect_to root_url
        else
          render :new and return
        end
      end
      format.js do
        render(:json => responseText, :status => responseText[:status] ) and return
      end
    end

  end

  # Helper to apply common defaults to cookie options
  def domain_cookie_opts(opts)
    defaults = {
      :secure => true,
      :path => '/'
    }
    if Rails.configuration.integrated
      defaults[:domain] = '.redhat.com'
    end
    defaults.merge(opts)
  end
end
