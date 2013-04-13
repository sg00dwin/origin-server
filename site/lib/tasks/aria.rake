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
      Aria::DirectPost.create("edit_#{plan}", url)
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
  task :generate_test_users => :environment do |t,args|
    if Rails.env.production?
      puts "Cannot be run in production environments"
    elsif ENV['ARIA_ADVANCE_VIRTUAL_DATETIME_ALLOWED']
      generate_test_users(false)
    else
      puts <<-eos

        Running this task will advance the Aria staging server virtual clock by up to a year.
        This task should only be run as needed to generate users for the automated tests.

        The environment variable ARIA_ADVANCE_VIRTUAL_DATETIME_ALLOWED is not set, running in dry-run mode

        Rerun with ARIA_ADVANCE_VIRTUAL_DATETIME_ALLOWED=true to actually create users

      eos
      generate_test_users(true)
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

  def generate_test_user(all_actions, id, create_date, user_actions={}, create_data={})
    id = "#{id}_#{create_date.strftime('%Y%m%d')}"
    user = Aria::UserContext.new(WebUser.new({
        :email_address=> id,
        :rhlogin=> id,
        :ticket => '1'
    }))

    #raise Aria::AccountExists if user.has_account?

    create = lambda do |dry_run,user,date,interval| 
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Create"
      return if dry_run
      if user.has_account?
        puts "\t\tAccount already exists, updating broker user to match current plan"
        next_plan = Aria::MasterPlan.for_plan_no(user.next_plan_no.to_i)
        User.find(:one, :as => user).tap{ |a| a.plan_id = next_plan.id; check a.save }
      else
        create_data[:test_acct_ind] ||= 0
        create_data[:billing_info] ||= Aria::BillingInfo.test
        check user.create_account create_data
        User.find(:one, :as => user).tap{ |a| a.plan_id = :free; check a.save }
        check_equal '1', user.account_details.bill_day
        check_equal '0', user.account_details.status_cd
        check_equal Aria.default_plan_no.to_s, user.account_details.plan_no
      end
    end

    all_actions[create_date] ||= []
    all_actions[create_date] << lambda {|dry_run| create.call(dry_run,user,create_date,0) }
    user_actions.each do |interval, interval_actions|
      if interval.class == Date
        date = interval
        interval = date - create_date
      else
        date = (create_date + interval)
      end

      date_actions = all_actions[date] = all_actions[date] || []
      Array(interval_actions).each do |action|
        date_actions << lambda {|dry_run| action.call(dry_run,user,date,interval) }
      end
    end
    id
  end

  def generate_test_users(dry_run)
    all_actions = {}

    set_date = lambda do |dry_run,date|
      puts "#{"(dry-run) " if dry_run}Set date to #{date}"
      return if dry_run
      virtual_date = Aria.get_virtual_datetime.virtual_date.to_date
      if virtual_date > date
        raise "Cannot travel back in time from #{virtual_date} to #{date}" if date < virtual_date
      elsif virtual_date < date
        days = (date - virtual_date).to_i
        if days > 0
          puts "\t\tAdvancing #{days*24} hours"
          Aria.advance_virtual_datetime(days * 24)
        end
      end
    end

    add_payment_method = lambda do |dry_run,user,date,interval| 
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
    end

    upgrade = lambda do |dry_run,user,date,interval| 
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Upgrade" 
      return if dry_run
      old = user.account_details
      check silver = Aria::MasterPlan.find('silver')
      User.find(:one, :as => user).tap{ |a| a.plan_id = :silver; check a.save }
      user.clear_cache!
      check_equal old.bill_day, user.account_details.bill_day
      check_equal silver.name, user.account_details.plan_name
    end

    downgrade = lambda do |dry_run,user,date,interval| 
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Downgrade" 
      return if dry_run
      old = user.account_details
      check free = Aria::MasterPlan.find('free')
      User.find(:one, :as => user).tap{ |a| a.plan_id = :free; check a.save }
      user.clear_cache!
      check_equal old.bill_day, user.account_details.bill_day
      check_equal old.plan_name, user.account_details.plan_name
      check_equal free.plan_no, user.next_plan_no
    end

    free = Aria::MasterPlan.find 'free'
    check free_s = Aria.get_client_plan_services(free.plan_no).find{ |s| s.client_coa_code == 'usage_gear_small' }
    record_free_usage = lambda do |dry_run,user, date, interval|
      small_amount = 1000 + [interval.to_i/3600, 1250].min
      usage_date = "#{date.to_s} 12:00:00"
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record free usage (small=#{small_amount} hours, usage_date=#{usage_date})" 
      return if dry_run
      Aria.record_usage(user.acct_no, free_s.usage_type, small_amount, {:comments => "Test free small gear hours usage", :usage_date => usage_date})
      u.clear_cache!
    end

    silver = Aria::MasterPlan.find 'silver'
    check silver_s = Aria.get_client_plan_services(silver.plan_no).find{ |s| s.client_coa_code == 'usage_gear_small' }
    check silver_m = Aria.get_client_plan_services(silver.plan_no).find{ |s| s.client_coa_code == 'usage_gear_medium' }
    record_silver_usage_under = lambda do |dry_run,user, date, interval|
      small_amount = 1000 + [interval.to_i/3600, 1250].min
      usage_date = "#{date.to_s} 12:00:00"
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record silver usage (small=#{small_amount} hours, usage_date=#{usage_date}) under the free limit" 
      return if dry_run
      Aria.record_usage(user.acct_no, silver_s.usage_type, small_amount, {:comments => "Test silver small gear hours usage under free cutoff", :usage_date => usage_date})
      user.clear_cache!
    end
    record_silver_usage_over = lambda do |dry_run,user,date,interval| 
      small_amount = 3000 + interval.to_i/3600
      medium_amount = 100 + interval.to_i/3600
      usage_date = "#{date.to_s} 12:00:00"
      puts "#{"(dry-run) " if dry_run}\t#{user.login}: Record silver usage (small=#{small_amount} hours, medium=#{medium_amount} hours, usage_date=#{usage_date}) over the free limit" 
      return if dry_run
      Aria.record_usage(user.acct_no, silver_s.usage_type, small_amount, {:comments => "Test small gear hours usage", :usage_date => usage_date})
      Aria.record_usage(user.acct_no, silver_m.usage_type, medium_amount, {:comments => "Test medium gear hours usage", :usage_date => usage_date})
      user.clear_cache!
    end

    # Always start on the next available March 1st
    aria_today = Aria::DateTime.today()
    start_date = aria_today.change({:month => 3, :day => 1})
    start_date += 1.year if start_date < aria_today

    age4          = start_date
    age4_prorated = start_date + 2.weeks
    age1          = start_date + 3.months
    age1_prorated = start_date + 3.months + 2.weeks
    age0          = start_date + 4.months
    age0_prorated = start_date + 4.months + 2.weeks
    ages          = [age0, age0_prorated,
                     age1, age1_prorated,
                     age4, age4_prorated].sort!
    end_date = ages.max


    banner "Free user"
    puts generate_test_user(all_actions, 'free', age0)


    banner "Free user with payment method"
    puts generate_test_user(all_actions, 'free_paymentmethod', age0, { 0.days => add_payment_method })

    banner "Free user with usage under the free limit"
    puts generate_test_user(all_actions, 'free_usageunder', age0, { 
      0.days => [record_free_usage]
    })

    banner "Megashift users"
    ages.each {|a|
      puts generate_test_user(all_actions, 'mega', a, { 0.days => [add_payment_method, upgrade] })
    }


    banner "Megashift users with historical and current usage over the free limit"
    puts generate_test_user(all_actions, 'mega_usageover', age4, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over,
      4.months => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_usageover', age1, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_usageover', age0, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over]
    })


    banner "Megashift users with historical and current usage under the free limit"
    puts generate_test_user(all_actions, 'mega_usageunder', age4, {
      0.days => [add_payment_method, upgrade, record_silver_usage_under],
      1.month => record_silver_usage_under,
      2.months => record_silver_usage_under,
      3.months => record_silver_usage_under,
      4.months => record_silver_usage_under
    })
    puts generate_test_user(all_actions, 'mega_usageunder', age1, {
      0.days => [add_payment_method, upgrade, record_silver_usage_under],
      1.month => record_silver_usage_under
    })
    puts generate_test_user(all_actions, 'mega_usageunder', age0, {
      0.days => [add_payment_method, upgrade, record_silver_usage_under]
    })


    banner "Megashift users with historical usage and no current usage"
    puts generate_test_user(all_actions, 'mega_historicalusageover', age4, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_historicalusageover', age1, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over]
    })


    banner "Megashift users with no historical usage and current usage"
    puts generate_test_user(all_actions, 'mega_historicalusageover', age4, {
      0.days => [add_payment_method, upgrade],
      end_date => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_historicalusageover', age1, {
      0.days => [add_payment_method, upgrade],
      end_date => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_historicalusageover', age0, {
      0.days => [add_payment_method, upgrade],
      end_date => record_silver_usage_over
    })


    banner "Megashift users downgraded to freeshift with historical and current usage"
    puts generate_test_user(all_actions, 'mega_free_usageover', age4, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over,
      4.months => record_silver_usage_over,
      end_date => downgrade
    })
    puts generate_test_user(all_actions, 'mega_free_usageover', age1, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over,
      end_date => downgrade
    })
    puts generate_test_user(all_actions, 'mega_free_usageover', age0, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      end_date => downgrade
    })


    banner "Megashift users downgraded to freeshift with no current usage"
    puts generate_test_user(all_actions, 'mega_free_historicalusageover', age4, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over,
      end_date => downgrade
    })
    puts generate_test_user(all_actions, 'mega_free_historicalusageover', age1, {
      0.days => [add_payment_method, upgrade, record_silver_usage_over],
      end_date => downgrade
    })
    puts generate_test_user(all_actions, 'mega_free_historicalusage', age0, {
      0.days => [add_payment_method, upgrade],
      end_date => downgrade
    })


    banner "Megashift user downgraded and upgraded several times in the same period"
    puts generate_test_user(all_actions, 'mega_free_mega', age0, { 
      0.days => [add_payment_method, upgrade],
      1.day => downgrade,
      2.days => upgrade,
      3.days => downgrade,
      4.days => upgrade
    })

    banner "Megashift users with delayed upgrades"
    puts generate_test_user(all_actions, 'mega_delayed_upgrade', age1, { 
      2.day => add_payment_method,
      4.days => record_free_usage,
      6.days => upgrade,
      8.days => record_silver_usage_over
    })
    puts generate_test_user(all_actions, 'mega_delayed_upgrade', age0, { 
      2.day => add_payment_method,
      4.days => record_free_usage,
      6.days => upgrade,
      8.days => record_silver_usage_over
    })

    banner "EUR user in US"
    puts generate_test_user(all_actions, 'mega_eur_in_us', age4, { 
      0.days => [add_payment_method, upgrade],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.new({
        :address1 => '12345 Happy Street',
        :city => 'Austin',
        :country => 'US',
        :region => 'TX',
        :zip => '10001',
        :currency_cd => "eur"
      })
    })

    banner "EUR user in DE"
    puts generate_test_user(all_actions, 'mega_eur_in_de', age4, { 
      0.days => [add_payment_method, upgrade],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.new({
        :address1 => '12345 Happy Street',
        :city => 'Berlin',
        :country => 'DE',
        :region => 'Burgenland',
        :zip => '10001',
        :currency_cd => "eur"
      })
    })

    banner "CAD user in CA"
    puts generate_test_user(all_actions, 'mega_cad_in_ca', age4, { 
      0.days => [add_payment_method, upgrade],
      1.month => record_silver_usage_over,
      2.months => record_silver_usage_over,
      3.months => record_silver_usage_over
    }, {
      :billing_info => Aria::BillingInfo.new({
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'CA',
        :region => 'NF',
        :zip => '10001',
        :currency_cd => "cad",
      })
    })

    banner "Actions"
    all_actions.sort.each {|date, actions|
      set_date.call(dry_run,date)
      actions.each {|a| a.call(dry_run) }
    }
    nil
  end

end
