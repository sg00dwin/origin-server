require 'mocha'
require 'streamline'

class ActiveSupport::TestCase
  #
  # Create a domain and user that are shared by all tests in the test suite, 
  # and is only destroyed at the very end of the suite.  If you do not clean
  # up after creating applications you will hit the application limit for
  # this user.
  # 
  # FIXME: reconcile with parent
  def with_domain_xxx
    setup_api
    setup_user
    once :domain do
      domain = Domain.first :as => @user
      @@domain = domain || setup_domain
      unless @with_unique_user
        lambda do
          @@domain.destroy_recursive rescue nil
          @@domain = nil
        end
      end
    end
    @domain = @@domain
  end
end
