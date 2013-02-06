require File.expand_path('../../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class RestApiDomainTest
  test 'user has capabilities' do
    assert user = User.find(:one, :as => @user)
    assert user.plan_upgrade_enabled
    assert user.plan_upgrade_enabled?
  end
end
