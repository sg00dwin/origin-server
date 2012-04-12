require File.expand_path('../../test_helper', __FILE__)

class CloudAccessTest < ActiveSupport::TestCase
  test "solution paths" do
    assert CloudAccess.req_role(CloudAccess::EXPRESS).index("request")
    assert !CloudAccess.auth_role(CloudAccess::EXPRESS).index("request")
  end
end
