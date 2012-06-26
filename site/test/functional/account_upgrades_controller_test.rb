require File.expand_path('../../test_helper', __FILE__)

class AccountUpgradesControllerTest < ActionController::TestCase

  def plan
    {:plan_id => :megashift}
  end
  def with_user(user)
    @user ||= begin
      @controller.expects(:current_user).at_least_once.returns(user)
      user_to_session(user)
    end
  end
  def simple
    WebUser.new :rhlogin => 'outside_user@gmail.com', :email_address => 'outside_user@gmail.com', :streamline_type => :full
  end
  def full
    WebUser.new :rhlogin => 'rhnuser', :email_address => 'rhnuser@redhat.com', :streamline_type => :full
  end

  test "should raise on invalid user" do
    user = with_user(full)
    user.expects(:extend).with(Aria::User)
    user.expects(:has_valid_account?).raises(Aria::UserIdCollision.new(1))
    post :upgrade, plan
    assert_response :success
    assert m = assigns(:message)
    assert m =~ /IDCOLLISION/, "Message was '#{m}'"
  end
end# if Aria.available?
