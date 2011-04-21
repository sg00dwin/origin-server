#
# This mixin module mocks the calls that are used
# for the IT streamline application
module StreamlineMock
  attr_accessor :rhlogin, :ticket, :roles, :terms, :site_terms

  def initialize
    @roles = []
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
  
  #
  # Get the user's email address
  #
  def establish_email_address    
    @email_address = 'test@example.com'
  end
  
  def establish_terms
    @terms = [{"termId"=>1046, "termUrl"=>"http://openshift.redhat.com/app/legal/pdf/services_agreement.pdf", "termTitle"=>"OpenShift Site Terms"}]
    @site_terms = [{"termId"=>1, "termUrl"=>"http://www.redhat.com/legal/legal_statement.html", "termTitle"=>"Red Hat Site Terms"},
     {"termId"=>1010, "termUrl"=>"https://access.redhat.com/help/terms_conditions.html", "termTitle"=>"Red Hat Portals Terms of Use"}]    
  end
  
  def accept_terms(accepted_terms_list)
  end

  def refresh_roles(force=false)  
  end

  #
  # Login the current user, setting the roles and ticket
  #
  def login
    Rails.logger.warn("Non integrated environment - faking login")
    if @email_address.index("@")
      Rails.logger.debug("Fake streamline login")
      @roles << "simple_authenticated"
    else
      Rails.logger.debug("Fake legacy login")
      @roles << "authenticated"
    end

    # Set a fake ticket
    @ticket = "test"
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
  def request_access(solution, amz_acct="")
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
    false
  end

  #
  # Whether the user has already requested access for a given cloud solution
  #
  def has_requested?(solution)
    false
  end
end
