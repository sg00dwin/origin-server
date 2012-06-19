require 'test_billing_helper'


class BillingEnablementTest < ActiveSupport::TestCase
  def setup
    @test_enabled = false
    # Create user locally first
    @user = CloudUser.new("aria_testuser_" + gen_uuid[0..9])
    @user.max_gears =0
    @user.save
    super
  end

  test "user billing plan lifecycle" do
    if @test_enabled
      api = Express::AriaBilling::Api.instance
      acct_no = api.create_fake_acct(@user.uuid, :FreeShift)


      # ensure the user has free account assigned only
      check_user_enablement(3, false)

      # upgrade master plan
      assert(api.update_master_plan(acct_no, :MegaShift))

      # check in mongo about the plan upgraded
      check_user_enablement(16, true)

      # now restore the user back to FreeShift
      # downgrade master plan
      assert(api.update_master_plan(acct_no, :FreeShift))
      
      # ensure the user has free account assigned only
      check_user_enablement(3, false)
    end
  end

  def check_user_enablement(target_max_gears, target_vip)
    user=nil
    10.times do
      user = CloudUser.find(@user.login)
      break if user.max_gears==target_max_gears
      sleep(6)
    end
    assert_equal(target_max_gears, user.max_gears)
    # ensure the user has target_vip status i.e. only small/medium gears allowed
    assert_equal(target_vip, user.vip)
  end

  def teardown
    @user.delete
  end
end
