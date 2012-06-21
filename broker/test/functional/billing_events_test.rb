require 'test_billing_helper'

class BillingEventsTest < ActiveSupport::TestCase
  def setup
    @test_enabled = false
    @api = Express::AriaBilling::Api.instance
  end

  test "billing events" do
    if @test_enabled
      userid = "aria_testuser_" + gen_uuid[0..9]
      # event: 101
      acct_no = @api.create_fake_acct(userid, :FreeShift)

      # event: 102
      assert(@api.update_acct_contact(acct_no))

      # event: 105
      assert(@api.update_acct_status(acct_no, -1))

      # event: 107
      assert(@api.update_master_plan(acct_no, :MegaShift))

      # event: 110
      assert(@api.assign_supp_plan(acct_no, :MegaShiftStorage))

      # event: 114
      assert(@api.modify_supp_plan(acct_no, :MegaShiftStorage, 5))

      # event: 112
      assert(@api.cancel_supp_plan(acct_no, :MegaShiftStorage))

      # event: 118
      assert(@api.update_acct_supp_fields(acct_no, 'BillCounty', 'Mercury'))

      # event: 119
      assert(@api.update_acct_supp_fields(acct_no, 'BillCounty', 'Saturn'))
    end
  end
end
