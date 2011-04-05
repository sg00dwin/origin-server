require 'test_helper'

class StreamlineTest < ActiveSupport::TestCase
  test "streamline urls" do
    assert Streamline.login_url.host
    assert Streamline.request_access_url.host
    assert Streamline.roles_url.host
    assert Streamline.email_confirm_url("abc123", "test@example.com").query
  end
end
