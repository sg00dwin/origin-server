require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test "check credentials" do
    @controller.check_credentials
  end
end
