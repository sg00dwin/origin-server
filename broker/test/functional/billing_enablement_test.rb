require 'test_helper'


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
      acct_no = api.create_fake_user(@user.uuid, :FreeShift)


      # ensure the user has free account assigned only
      check_user_enablement(@user, 3, false)

      # upgrade master plan
      result = api.update_master_plan(acct_no, :MegaShift)
      assert(0, result.error_code)

      # check in mongo about the plan upgraded
      check_user_enablement(@user, 16, true)

      # now restore the user back to FreeShift
      # downgrade master plan
      result = api.update_master_plan(acct_no, :FreeShift)
      assert(0, result.error_code)
      
      # ensure the user has free account assigned only
      check_user_enablement(@user, 3, false)
    end
  end

  def check_user_enablement(target_max_gears, target_vip)
    current_max_gears = @user.max_gears
    max_gears = current_max_gears
    [0..10].each { |i|
      @user = CloudUser.find(user.login)
      max_gears = @user.max_gears
      break unless  max_gears==current_max_gears
      sleep(4)
    }
    assert(target_max_gears, max_gears)
    # ensure the user has target_vip status i.e. only small/medium gears allowed
    assert(target_vip, @user.vip)
  end

  def teardown
    @user.delete
  end
end
