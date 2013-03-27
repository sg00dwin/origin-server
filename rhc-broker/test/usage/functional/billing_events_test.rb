ENV["TEST_NAME"] = "usage_funtional_billing_events_test"
require 'test_helper'

class BillingEventsTest < ActiveSupport::TestCase
  def setup
    @api = OpenShift::BillingService.instance
  end

  test "billing events" do
    billing_config = Rails.application.config.billing[:config]
    if billing_config[:enable_event_notification]
      userid = "billing_testuser_" + gen_uuid[0..9]
      # event: 101
      acct_no = @api.create_fake_acct(userid, :free)

      # event: 102
      assert(@api.update_acct_contact(acct_no))

      # event: 105
      assert(@api.update_acct_status(acct_no, -1))

      # event: 107
      assert(@api.update_master_plan(acct_no, :silver))

=begin # As of now, we are NOT using supplimental plans
      # event: 110
      assert(@api.assign_supp_plan(acct_no, :silverstorage))
      # event: 114
      assert(@api.modify_supp_plan(acct_no, :silverstorage, 5))
      # event: 112
      assert(@api.cancel_supp_plan(acct_no, :silverstorage))
=end

      # event: 118
      assert(@api.update_acct_supp_fields(acct_no, 'BillCounty', 'Mercury'))

      # event: 119
      assert(@api.update_acct_supp_fields(acct_no, 'BillCounty', 'Saturn'))
    end
  end
end
