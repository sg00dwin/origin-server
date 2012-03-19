#
# This mixin module mocks the calls that are used
# for the IT streamline application
module StreamlineMock
  attr_accessor :rhlogin, :ticket, :roles, :terms

  def initialize
    @roles = []
    @terms = []
  end

  #
  # Establish the user state based on the current ticket
  #
  # Returns the login
  #
  def establish
    Rails.logger.warn("Non integrated environment - passing through")
    @roles << "simple_authenticated"
    @rhlogin = "openshift@redhat.com"
  end

  def terms
    @terms
  end

  def roles
    @roles
  end

  #
  # Get the user's email address
  #
  def establish_email_address
    @email_address = 'test@example.com'
  end

  def establish_terms
    if @rhlogin == nil || @rhlogin == 'terms+test@redhat.com'
      @terms = [{"termId"=>1046, "termUrl"=>"http://openshift.redhat.com/app/legal/pdf/services_agreement.pdf", "termTitle"=>"OpenShift Site Terms"},
                {"termId"=>1, "termUrl"=>"http://www.redhat.com/legal/legal_statement.html", "termTitle"=>"Red Hat Site Terms"},
                {"termId"=>1010, "termUrl"=>"https://access.redhat.com/help/terms_conditions.html", "termTitle"=>"Red Hat Portals Terms of Use"}]
    else
      @terms = []
    end
  end

  def accept_terms
    @terms = []
  end

  def refresh_roles(force=false)
  end

  def change_password(args=nil)
    if args.nil?
      if valid? :change_password
        return true
      else
        if @old_password == 'invalid_old_password'
          errors.add :old_password, "Your old password is not valid"
        end
        return false
      end
    end
    return {'errors' => ['password_invalid']} unless args['newPassword'] == args['newPasswordConfirmation']
    return {'errors' => ['password_incorrect']} if args['oldPassword'] == 'invalid_old_password'
    return {}
  end

  def request_password_reset(args)
    Rails.logger.debug "Requesting password reset"
    if args.is_a? String
      valid? :reset_password
    else
      {}
    end
  end

  def reset_password(args=nil)
    if args.nil?
      valid? :change_password
    else
      {}
    end
  end

  def complete_reset_password(token)
    raise Streamline::TokenExpired if token.blank?
    true
  end

  def authenticate(login, password)
    if login.present? and password.present?
      @rhlogin = login
      @ticket = 'test'
      true
    else
      errors.add(:base, I18n.t(:login_error, :scope => :streamline))
      false
    end
  end

  def streamline_cookie
    "rh_sso=#{@ticket}"
  end

  #
  # Register a new streamline user
  #
  def register(confirm_url)
    Rails.logger.warn("Non integrated environment - passing through")
  end

  def confirm_email(key, email=@email_address)
    raise "No email address provided" unless email
    true
  end

  #
  # Request access to a cloud solution
  #
  def request_access(solution)
    # Check if this is an integrated environment
    unless Rails.configuration.integrated
      Rails.logger.warn("Non integrated environment - adding role")
      @roles << CloudAccess.auth_role(solution)
      return
    end
  end

  #
  # Whether the user is authorized for a given cloud solution
  #
  def has_access?(solution)
    unless @rhlogin == 'allaccess+test@redhat.com'
      !@roles.index(CloudAccess.auth_role(solution)).nil?
    else
      true
    end
  end

  #
  # Whether the user has already requested access for a given cloud solution
  #
  def has_requested?(solution)
    unless @rhlogin == 'allaccess+test@redhat.com'
      !@roles.index(CloudAccess.req_role(solution)).nil?
    else
      false
    end
  end

  def entitled?
    has_access(CloudAccess::EXPRESS)
  end

  def waiting_for_entitle?
    has_requested(CloudAccess::EXPRESS)
  end
end
