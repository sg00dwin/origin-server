require 'test_helper'

class OpenshiftTest < ActiveSupport::TestCase
  
  def setup
    @user = WebUser.new
    @user.authenticate('test@example.com','secret')
  end
  
  test "ssh keys should be successfully retrieved" do
    items = SshKey.find :all, :as => @user
    assert items.is_a? Array
  end
end
