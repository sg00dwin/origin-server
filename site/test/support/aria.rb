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
        rescue Aria::AccountExists
        end
        u.account_details
      end
    end
    set_user(@@account_holder.dup)
  end

  def with_aria_user(id=nil, retroactive_start_date=nil)
    user = nil
    begin
      id = id ? create_user_id(id) : new_uuid
      user = Aria::UserContext.new(WebUser.new({
          :email_address=> id,
          :rhlogin=>       id,
          :ticket => '1'
      }))
      begin
        assert user.create_account :test_acct_ind => 0,
                                   :retroactive_start_date => retroactive_start_date
        assert_equal '1', user.account_details.bill_day
        assert_equal '0', user.account_details.status_cd
        assert_equal Aria.default_plan_no.to_s, user.account_details.plan_no
      rescue Aria::AccountExists
      end
      set_user(user)

      yield user
    ensure
      teardown_user(user)
    end
  end

  def set_billing_info(user)
    old = user.account_details
    assert user.update_account :billing_info => Aria::BillingInfo.test
    assert_equal old.status_cd, user.account_details.status_cd
    assert_equal old.bill_day, user.account_details.bill_day
    assert_equal old.plan_no, user.account_details.plan_no
    user.clear_cache!
  end

  def set_payment_method(user)
    # Have to pass test_acct_ind to keep aria from turning this into a test user
    p = Aria::PaymentMethod.test
    old = user.account_details
    assert user.update_account :pay_method => 1,
                               :cc_number => p.cc_no,
                               :cc_expire_mm => p.cc_expire_mm,
                               :cc_expire_yyyy => p.cc_expire_yyyy,
                               :status_cd => 1,
                               :test_acct_ind => 0
    assert_equal old.bill_day, user.account_details.bill_day
    assert_equal old.plan_no, user.account_details.plan_no
    assert_equal '1', user.account_details.status_cd
    assert_false user.test_user?
    user.clear_cache!
  end

  def upgrade_user(user)
    # TODO: pass through broker
    old = user.account_details
    assert mega = Aria::MasterPlan.find('megashift')
    assert user.update_account :master_plan_no => mega.plan_no,
                               :master_plan_assign_directive => 2
    assert_equal old.bill_day, user.account_details.bill_day
    assert_equal mega.name, user.account_details.plan_name
    user.clear_cache!
  end

  def invoice_and_charge(user)
    Aria.gen_invoice :acct_no => user.acct_no
    Aria.settle_account_balance :account_no => user.acct_no
    user.clear_cache!
  end

  def teardown_user(user)
    warn ("Can't clean up nil user") if user.nil?
    assert user.update_account :test_acct_ind => 1 if user
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

  def record_usage_for_user(u, small_usage=10, medium_usage=5, usage_date=nil)
    p = Aria::MasterPlan.find 'megashift'
    assert s = Aria.get_client_plan_services(p.plan_no).find{ |s| s.client_coa_code == 'smallusage' }
    assert m = Aria.get_client_plan_services(p.plan_no).find{ |s| s.client_coa_code == 'mediumusage' }
    Aria.record_usage(u.acct_no, s.usage_type, small_usage, {:comments => "Test small gear hours usage", :usage_date => usage_date})
    Aria.record_usage(u.acct_no, m.usage_type, medium_usage, {:comments => "Test medium gear hours usage", :usage_date => usage_date})
    u.clear_cache!
    u
  end

  def create_user_id(tag, prefix="jtl-")
    id = "#{prefix}#{tag.gsub(/[^a-z0-9]+/i, '-')}-#{Time.now.strftime("%Y%m%d-%H%M%S")}"
    puts id
    id
  end
end
