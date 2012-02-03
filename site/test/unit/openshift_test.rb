require 'test_helper'

class OpenshiftTest < ActiveSupport::TestCase
  
  def setup
    @user = WebUser.authenticate('test@example.com','secret')
  end
  
  test "ssh keys should be successfully retrieved" do
    SshKey.find :all, :as => @user
  end
end
