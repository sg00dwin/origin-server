require 'recaptcha'

class TermsController < SiteController

  def new
    new_terms
  end

  def acceptance_terms
    new_terms
    @term_description = {
      'OpenShift Service Agreement' => 'This agreement contains the terms and conditions that apply to your access and use of the OpenShift Preview Services and Software. The Agreement also incorporates the Acceptable Use Policy which can be reviewed at http://openshift.redhat.com/app/legal.',   
      'Red Hat Site Terms' => "These terms apply to use of Red Hat's websites, including this OpenShift site.", 
      'Red Hat Portals Terms of Use' => 'These terms apply to the extent you use the Red Hat Customer Portal website.' 
    }
  end
  
  def new_terms
    @user = session_user
    if @user
      if @user.terms.empty?
        #TODO would like this to show the terms they have already accepted
        redirect_to legal_site_terms_path and return
      end

      @term = Term.new

      if !@user.roles.index('simple_authenticated')
        @show_captcha = true
        @button_class = 'captcha'
      else
        @show_captcha = false
        @button_class = 'no-captcha'
      end
    else
      redirect_to login_path
    end
  end

  def create
    @user = session_user
    @term = Term.new
    if @user
      logger.debug "Accepting terms for user #{@user.pretty_inspect}"

      if !@user.roles.index('simple_authenticated')
        @show_captcha = true
        @button_class = 'captcha'

        if params[:captcha_secret] == Rails.configuration.captcha_secret
          logger.warn "Captcha secret provided - ignoring captcha"
        else
          logger.debug "Checking captcha"
          # Verify the captcha
          unless verify_recaptcha
            logger.debug "Captcha check failed"
            @term.errors[:captcha] = "Captcha text didn't match"
            # Stop if you have a validation error
            render :new and return
          end
        end
      else
        logger.warn "Simple user - no captcha" 
        @show_captcha = false
        @button_class = 'no-captcha'
      end

      @user.accept_terms unless @user.terms.empty?

      if @user.errors.empty?
        redirect_to terms_redirect
      else
        logger.debug "Found errors, updating terms object with #{@user.errors}"
        @term.errors.update(@user.errors)
        render :new
      end
    else
      redirect_to login_path
    end
  end

end
