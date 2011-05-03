require 'pp'
require 'json'
require 'recaptcha'

class TermsController < ApplicationController

  def new
    new_terms
    if !@user.roles.index('simple_authenticated')
    #if true
      @show_captcha = true
      @button_class = 'captcha'
    else
      @show_captcha = false
      @button_class = 'no-captcha'
    end
  end

  def acceptance_terms
    new_terms
    @term_description = {           
      'OpenShift Service Agreement' => 'This agreement contains the terms and conditions that apply to your access and use of the Openshift Preview Services and Software. The Agreement also incorporates the Acceptable Use Policy which can be reviewed at http://openshift.redhat.com/app/legal.',   
      'Red Hat Site Terms' => 'These terms apply to use of Red Hat’s websites, including this OpenShift site.', 
      'Red Hat Portals Terms of Use' => 'These terms apply to the extent you use the Red Hat Customer Portal website.' 
    }
  end
  
  def new_terms
    @user = session_user
    if @user
      @user.establish_terms
      if @user.terms.length > 0
        @term = Term.new
      else
        #TODO would like this to show the terms they have already accepted
        redirect_to legal_site_terms_path and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_terms_path
      redirect_to login_path
    end
  end

  def create
    @user = session_user
    @term = Term.new
    if @user
      logger.debug "Accepting terms for user #{@user.pretty_inspect}"
      
      # See if the captcha secret was provided
      if Rails.configuration.integrated
        if !@user.roles.index('simple_authenticated')
          if params[:captcha_secret] == Rails.configuration.captcha_secret
            Rails.logger.warn "Captcha secret provided - ignoring captcha"
          else
            Rails.logger.debug "Checking captcha"
            # Verify the captcha
            unless verify_recaptcha
              Rails.logger.debug "Captcha check failed"
              @term.errors[:captcha] = "Captcha text didn't match"
              # Stop if you have a validation error
              render :new and return            
            end
          end
        else
          Rails.logger.warn "Simple user - no captcha"
        end
      else
        Rails.logger.warn "Non-integrated environment - ignoring captcha"
      end
      
      @user.accept_terms unless @user.terms.empty?
      
      if @user.errors.length > 0
        logger.debug "Found errors, updating terms object with #{@user.errors}"
        @term.errors.update(@user.errors)
        render :new and return
      else
        # This is the key to get past terms checking in application controller
        session[:login] = @user.rhlogin
      end

      if workflow_redirect
        return
      else
        redirect_to root_path and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_terms_path
      redirect_to login_path
    end
  end

end
