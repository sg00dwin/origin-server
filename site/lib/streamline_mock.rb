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

  def change_password(args)
    return {}
  end

  def authenticate(login, password)
    @rhlogin = login
    @ticket = nil
    true
  end

  def streamline_cookie
    [:rh_sso, {:secure => true, :path => '/', :domain => '.redhat.com', :value => 'mock'}]
  end

  #
  # Register a new streamline user
  #
  def register(confirm_url)
    Rails.logger.warn("Non integrated environment - passing through")
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
