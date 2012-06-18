require 'test_helper'

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
      result = @api.update_acct_contact(acct_no)
      assert(result, true)

      # event: 105
      result = @api.update_acct_status(acct_no, 0)
      assert(result, true)

      # event: 107
      result = @api.update_master_plan(acct_no, :MegaShift)
      assert(result, true)

      # event: 110
      result = @api.assign_supp_plan(acct_no, :MegaShiftStorage)
      assert(result, true)

      # event: 114
      result = @api.modify_supp_plan(acct_no, :MegaShiftStorage, 5)
      assert(result, true)

      # event: 112
      result = @api.cancel_supp_plan(acct_no, :MegaShiftStorage)
      assert(result, true)

      # event: 120
      result = @api.update_acct_supp_fields(acct_no, 'BillCounty', '')
      assert(result, true)

      # event: 118
      result = @api.update_acct_supp_fields(acct_no, 'BillCounty', 'Mercury')
      assert(result, true)

      # event: 119
      result = @api.update_acct_supp_fields(acct_no, 'BillCounty', 'Saturn')
      assert(result, true)
    end
  end
end
