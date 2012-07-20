require 'test_helper'

class BillingEnablementTest < ActiveSupport::TestCase
  def setup
    @test_enabled = false
    # Create user locally first
    @user = CloudUser.new("aria_testuser_" + gen_uuid[0..9])
    @user.max_gears =0
    @user.save
    @user_id = Digest::MD5::hexdigest(@user.login)
    super
  end

  test "user billing plan lifecycle" do
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      acct_no = api.create_fake_acct(@user_id, :freeshift)

      # ensure the user has free account assigned only
      check_user_enablement(3, false)

      # upgrade master plan
      assert(api.update_master_plan(acct_no, :megashift))

      # check in mongo about the plan upgraded
      check_user_enablement(16, true)

      # now restore the user back to FreeShift
      # downgrade master plan
      assert(api.update_master_plan(acct_no, :freeshift))

      # ensure the user has free account assigned only
      check_user_enablement(3, false)
    end
  end

  def check_user_enablement(target_max_gears, target_vip)
    # Settings should take affect immediately in the broker.  All changes should follow the pattern:
    # Check the change is valid with the broker and indicate the intended change with the broker
    # Call the billing provider to make the change
    # On success update the broker that the change is made
    user = CloudUser.find(@user.login)

    assert_equal(target_max_gears, user.max_gears)
    # ensure the user has target_vip status i.e. only small/medium gears allowed
    assert_equal(target_vip, user.vip)
  end

  def teardown
    @user.delete
  end
end
