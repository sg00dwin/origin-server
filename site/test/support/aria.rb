class ActiveSupport::TestCase
  def with_account_holder
    @@account_holder ||= begin
      Aria::UserContext.new(WebUser.new({
        :email_address=> "openshift_test_account_perm_1",
        :rhlogin=>       "openshift_test_account_perm_1",
        :ticket => '1'
      })).tap do |u|
        begin
          create_megashift_user(u)
          record_usage_for_user(u)
          Aria.gen_invoice(:acct_no => u.acct_no)
        rescue Aria::AccountExists
        end
        u.account_details
      end
    end
    set_user(@@account_holder.dup)
  end

  def with_megashift_user
    user = Aria::UserContext.new(WebUser.new :login => new_uuid)
    create_megashift_user(user)
    set_user(user)
  end

  def omit_if_aria_is_unavailable
    omit("Aria not available; omitting test.") unless Aria.available?
  end

  def create_megashift_user(u)
    assert u.create_account :billing_info => Aria::BillingInfo.test,
                            :payment_method => Aria::PaymentMethod.test,
                            :test_acct_ind => 0,
                            :status_cd => 1
    User.find(:one, :as => u).tap{ |a| a.plan_id = :megashift; assert a.save }
  end

  def record_usage_for_user(u)
    p = Aria::MasterPlan.find 'megashift'
    assert s = Aria.get_client_plan_services(p.plan_no).find{ |s| s.client_coa_code == 'smallusage' }
    assert m = Aria.get_client_plan_services(p.plan_no).find{ |s| s.client_coa_code == 'mediumusage' }
    Aria.record_usage(u.acct_no, s.usage_type, 10, :comments => "Test small gear hours usage")
    Aria.record_usage(u.acct_no, m.usage_type, 5, :comments => "Test medium gear hours usage")
    u
  end
end
