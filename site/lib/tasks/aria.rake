namespace :aria do
  desc 'Update Aria with the direct post settings for this server.'
  task :set_direct_post => :environment do
    name_prefix = Rails.configuration.aria_direct_post_name
    raise "aria_direct_post_name is nil (development mode).  This task requires it to be set." if name_prefix.nil?
    base = Rails.configuration.aria_direct_post_redirect_base
    raise "aria_direct_post_redirect_base is nil (development mode).  This task requires it to be set." if base.nil?

    urls = Rails.application.routes.url_helpers

    puts "Set direct post configuration for default edit"
    Aria::DirectPost.create('account', "#{base}#{urls.direct_update_account_payment_method_path}")

    Plan.all.each do |plan|
      name = Aria::DirectPost.get_configured(plan)
      path = urls.direct_create_account_plan_upgrade_payment_method_path(plan)
      url = "#{base}#{path}"
      puts "Set direct post configuration '#{name}' to redirect to '#{url}'"

      Aria::DirectPost.create(plan, url)
      Aria::DirectPost.create("edit_#{plan.id}", url)
      puts "  Settings: #{Aria.get_reg_uss_config_params("direct_post_#{name}").inspect}"
    end
  end

  desc 'Reset all API only Aria resources to their default state'
  task :clean => :environment do
    puts "Deleting config params for default direct post"
    Aria::DirectPost.destroy("account")

    Plan.all.each do |plan| 
      if name = Aria::DirectPost.get_configured(plan)
        puts "Deleting config params for direct post #{name}"
        Aria::DirectPost.destroy(name)
        Aria::DirectPost.destroy("edit_#{name}")
      end
    end
  end

  desc 'Check that the configuration is valid.'
  task :check => :environment do
  end

  desc 'Generate test users (non-production only)'
  task :generate_test_users, [:commit] => :environment do |t,args|
    args.with_defaults(:commit => false)
    if Rails.env.production?
      puts "Cannot be run in production environments"
    else
      dry_run = args[:commit] != 'true'
      puts "Run generate_test_users[true] to commit changes" if dry_run
      generate_test_users(dry_run)
    end
  end





  private

  def check condition
    raise Error unless condition
  end
  def check_equal a, b
    raise "#{a} != #{b}" unless a == b
  end

  def banner msg
    puts "\n#{msg}\n=================="
  end

  def make_id(id, create_date)
    #"#{id}_#{create_date.strftime('%Y%m%d')}_#{Time.new.to_i}"
    "#{id}_#{create_date.strftime('%Y%m%d')}"
  end


  def action(name)
    @free ||= Aria::MasterPlan.find 'free'
    check @free_s ||= Aria.get_client_plan_services(@free.plan_no).find{ |s| s.client_coa_code == 'usage_gear_small' }

    @silver ||= Aria::MasterPlan.find 'silver'
    check @silver_s ||= Aria.get_client_plan_services(@silver.plan_no).find{ |s| s.client_coa_code == 'usage_gear_small' }
    check @silver_m ||= Aria.get_client_plan_services(@silver.plan_no).find{ |s| s.client_coa_code == 'usage_gear_medium' }

    @actions ||= {
      :create => lambda do |dry_run,user,date,interval,create_data| 
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Create on #{date}"
        return if dry_run
        if user.has_account?
          puts "\t\tAccount already exists, updating broker user to match current plan"
          next_plan = Aria::MasterPlan.for_plan_no(user.next_plan_no.to_i)
          User.find(:one, :as => user).tap{ |a| a.plan_id = next_plan.id; check a.save }
          return false
        else
          create_data[:retroactive_start_date] = date.to_s
          create_data[:test_acct_ind] ||= 0
          create_data[:billing_info] ||= Aria::BillingInfo.test
          create_data[:contact_info] ||= Aria::ContactInfo.from_billing_info(create_data[:billing_info])
          check user.create_account(create_data)
          User.find(:one, :as => user).tap{ |a| a.plan_id = :free; check a.save }

          if date.day != 1
            # Hack to advance bill_day to 1 for retroactive_start_date users
            next_bill_date = date.change({:day => 1}) + 1.month
            delta = (next_bill_date - date).to_i
            Aria.adjust_billing_dates :acct_no => user.acct_no, :action_directive => 1, :adjustment_days => delta
            user.clear_cache!
          end

          check_equal '1', user.account_details.bill_day
          check_equal '0', user.account_details.status_cd
          check_equal Aria.default_plan_no.to_s, user.account_details.plan_no
        end
      end,

      :batch_bill => lambda do |dry_run,user,date,interval|
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Bill"
        return if dry_run
        Aria.gen_invoice :acct_no => user.acct_no
        Aria.settle_account_balance :account_no => user.acct_no
        Aria.gen_statement :acct_no => user.acct_no
      end,

      :add_payment_method => lambda do |dry_run,user,date,interval| 
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Add payment method" 
        return if dry_run
        # Have to pass test_acct_ind to keep aria from turning this into a test user
        p = Aria::PaymentMethod.test
        old = user.account_details
        check user.update_account :pay_method => 1,
                                   :cc_number => p.cc_no,
                                   :cc_expire_mm => p.cc_expire_mm,
                                   :cc_expire_yyyy => p.cc_expire_yyyy,
                                   :status_cd => 1
        # Hack needed when setting payment info to a test credit card
        check user.update_account :test_acct_ind => 0
        check_equal old.bill_day, user.account_details.bill_day
        check_equal old.plan_no, user.account_details.plan_no
        check_equal '1', user.account_details.status_cd
        check !user.test_user?
        user.clear_cache!
      end,

      :upgrade => lambda do |dry_run,user,date,interval| 
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Upgrade" 
        return if dry_run
        old = user.account_details
        User.find(:one, :as => user).tap{ |a| a.plan_id = :silver; check a.save }

        # Only necessary to simulate the automated invoice creation
        Aria.gen_invoice :acct_no => user.acct_no
        Aria.settle_account_balance :account_no => user.acct_no
        Aria.gen_statement :acct_no => user.acct_no

        user.clear_cache!
        check_equal old.bill_day, user.account_details.bill_day
        check_equal @silver.name, user.account_details.plan_name
      end,

      :downgrade => lambda do |dry_run,user,date,interval| 
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Downgrade" 
        return if dry_run
        old = user.account_details
        User.find(:one, :as => user).tap{ |a| a.plan_id = :free; check a.save }
        user.clear_cache!
        check_equal old.bill_day, user.account_details.bill_day
        check_equal old.plan_name, user.account_details.plan_name
        check_equal @free.plan_no.to_s, user.next_plan_no.to_s
      end,

      :record_free_usage => lambda do |dry_run,user, date, interval|
        small_amount = 1000 + [interval.to_i/3600, 1250].min
        usage_date = "#{date.to_s} 12:00:00"
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record free usage (s=#{small_amount} hours, date=#{usage_date})" 
        return if dry_run
        Aria.record_usage(user.acct_no, @free_s.usage_type, small_amount, {:comments => "Test free small gear hours usage", :usage_date => usage_date})
        user.clear_cache!
      end,

      :record_silver_usage_under => lambda do |dry_run,user, date, interval|
        small_amount = 1000 + [interval.to_i/3600, 1250].min
        usage_date = "#{date.to_s} 12:00:00"
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record silver usage (s=#{small_amount} hours, date=#{usage_date}) under the free limit" 
        return if dry_run
        Aria.record_usage(user.acct_no, @silver_s.usage_type, small_amount, {:comments => "Test silver small gear hours usage under free cutoff", :usage_date => usage_date})
        user.clear_cache!
      end,

      :record_silver_usage_over => lambda do |dry_run,user,date,interval| 
        small_amount = 3000 + interval.to_i/3600
        medium_amount = 100 + interval.to_i/3600
        usage_date = "#{date.to_s} 12:00:00"
        puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record silver usage (s=#{small_amount} hours, m=#{medium_amount} hours, date=#{usage_date}) over the free limit" 
        return if dry_run
        Aria.record_usage(user.acct_no, @silver_s.usage_type, small_amount, {:comments => "Test small gear hours usage", :usage_date => usage_date})
        Aria.record_usage(user.acct_no, @silver_m.usage_type, medium_amount, {:comments => "Test medium gear hours usage", :usage_date => usage_date})
        user.clear_cache!
      end
    }

    @actions[name]

  end

  def generate_test_user(id, create_date, user_actions, create_data, dry_run)
    all_actions = {}

    user = Aria::UserContext.new(WebUser.new({
        :email_address=> id,
        :rhlogin=> id,
        :ticket => '1'
    }))

    today = Aria::DateTime.today
    batch_date = create_date.change({:day => 1}) + 1.month
    while batch_date < today
      all_actions[batch_date] ||= []
      all_actions[batch_date] << lambda {|dry_run| action(:batch_bill).call(dry_run,user,batch_date,0) }
      batch_date = batch_date + 1.month
    end

    end_date = create_date
    all_actions[create_date] ||= []
    all_actions[create_date] << lambda {|dry_run| action(:create).call(dry_run,user,create_date,0,create_data) }
    user_actions.each do |interval, interval_actions|
      if interval.class == Date
        date = interval
        interval = date - create_date
      else
        date = (create_date + interval)
      end
      end_date = [end_date, date].max

      date_actions = all_actions[date] = all_actions[date] || []
      Array(interval_actions).each do |action_name|
        date_actions << lambda {|dry_run| action(action_name).call(dry_run,user,date,interval) }
      end
    end

    # Mark as test user after finishing
    # all_actions[end_date] ||= []
    # all_actions[end_date] << lambda do |dry_run|
    #   puts "\tSetting #{id} to test user"
    #   user.update_account :test_acct_ind => 1
    #   check user.test_user?
    # end

    puts "#{"(dry-run) " if dry_run}#{id}"
    all_actions.sort.each {|date, actions|
      puts "#{"(dry-run) " if dry_run}Date: #{date}"
      actions.each do |a|
        puts "#{"(dry-run) " if dry_run}\t\tskipping remaining steps..." and break if a.call(dry_run) === false
      end
    }
    puts
  end

  def generate_test_users(dry_run)

    # Always start on the next available March 1st
    aria_today = Aria::DateTime.today()
    start_date = (aria_today - 4.months - 2.weeks).change({:day => 1})

    age4          = start_date
    age1          = start_date + 3.months
    age0          = start_date + 4.months
    ages          = [age0, age1, age4].sort!
    end_date = ages.max

    banner "Free user"
    generate_test_user(make_id('free', age0), age0, {}, {}, dry_run)


    banner "Free user with payment method"
    generate_test_user(make_id('free_paymentmethod', age0), age0, { 0.days => :add_payment_method }, {}, dry_run)

    banner "Free user with usage under the free limit"
    generate_test_user(make_id('free_usageunder', age0), age0, { 
      0.days => [:record_free_usage]
    }, {}, dry_run)

    banner "Megashift users"
    ages.each {|a|
      generate_test_user(make_id('mega', a), a, { 0.days => [:add_payment_method, :upgrade] }, {}, dry_run)
    }


    banner "Megashift users with historical and current usage over the free limit"
    generate_test_user(make_id('mega_usageover', age4), age4, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over,
      4.months => :record_silver_usage_over
    }, {}, dry_run)
    generate_test_user(make_id('mega_usageover', age1), age1, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over
    }, {}, dry_run)
    generate_test_user(make_id('mega_usageover', age0), age0, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over]
    }, {}, dry_run)


    banner "Megashift users with historical and current usage under the free limit"
    generate_test_user(make_id('mega_usageunder', age4), age4, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_under],
      1.month => :record_silver_usage_under,
      2.months => :record_silver_usage_under,
      3.months => :record_silver_usage_under,
      4.months => :record_silver_usage_under
    }, {}, dry_run)
    generate_test_user(make_id('mega_usageunder', age1), age1, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_under],
      1.month => :record_silver_usage_under
    }, {}, dry_run)
    generate_test_user(make_id('mega_usageunder', age0), age0, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_under]
    }, {}, dry_run)


    banner "Megashift users with historical usage and no current usage"
    generate_test_user(make_id('mega_historicalusageover', age4), age4, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over
    }, {}, dry_run)
    generate_test_user(make_id('mega_historicalusageover', age1), age1, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over]
    }, {}, dry_run)


    banner "Megashift users with no historical usage and current usage"
    generate_test_user(make_id('mega_historicalusageover', age4), age4, {
      0.days => [:add_payment_method, :upgrade],
      end_date => :record_silver_usage_over
    }, {}, dry_run)
    generate_test_user(make_id('mega_historicalusageover', age1), age1, {
      0.days => [:add_payment_method, :upgrade],
      end_date => :record_silver_usage_over
    }, {}, dry_run)
    generate_test_user(make_id('mega_historicalusageover', age0), age0, {
      0.days => [:add_payment_method, :upgrade],
      end_date => :record_silver_usage_over
    }, {}, dry_run)


    banner "Megashift users downgraded to freeshift with historical and current usage"
    generate_test_user(make_id('mega_free_usageover', age4), age4, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over,
      4.months => :record_silver_usage_over,
      end_date => :downgrade
    }, {}, dry_run)
    generate_test_user(make_id('mega_free_usageover', age1), age1, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over,
      end_date => :downgrade
    }, {}, dry_run)
    generate_test_user(make_id('mega_free_usageover', age0), age0, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      end_date => :downgrade
    }, {}, dry_run)


    banner "Megashift users downgraded to freeshift with no current usage"
    generate_test_user(make_id('mega_free_historicalusageover', age4), age4, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over,
      end_date => :downgrade
    }, {}, dry_run)
    generate_test_user(make_id('mega_free_historicalusageover', age1), age1, {
      0.days => [:add_payment_method, :upgrade, :record_silver_usage_over],
      end_date => :downgrade
    }, {}, dry_run)
    generate_test_user(make_id('mega_free_historicalusage', age0), age0, {
      0.days => [:add_payment_method, :upgrade],
      end_date => :downgrade
    }, {}, dry_run)


    banner "Megashift user downgraded and upgraded several times in the same period"
    generate_test_user(make_id('mega_free_mega', age0), age0, { 
      0.days => [:add_payment_method, :upgrade, :downgrade, :upgrade, :downgrade, :upgrade]
    }, {}, dry_run)

    banner "USD user"
    generate_test_user(make_id('mega_usd', age4), age4, { 
      0.days => [:add_payment_method, :upgrade],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.test({
        :region => 'SD',
        :country => 'US'
      })
    }, dry_run)

    banner "EUR user"
    generate_test_user(make_id('mega_eur', age4), age4, { 
      0.days => [:add_payment_method, :upgrade],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.test({
        :city => 'Hamilton',
        :region => 'LAN',
        :country => 'GB',
        :zip => 'ML31A1'
      })
    }, dry_run)

    banner "CAD user"
    generate_test_user(make_id('mega_cad', age4), age4, { 
      0.days => [:add_payment_method, :upgrade],
      1.month => :record_silver_usage_over,
      2.months => :record_silver_usage_over,
      3.months => :record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.test({
        :city => 'Quebec City',
        :region => 'QC',
        :country => 'CA',
        :zip => 'L8E1A1'
      })
    }, dry_run)

    nil
  end

end



