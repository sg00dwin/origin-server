class CloudUser
  #
  # Capability keys that should be preserved when a user's plan changes.
  #
  PRESERVE_CAPABILITIES_ON_PLAN_CHANGE = ['plan_upgrade_enabled']
  PLAN_STATES = { 'active' => "ACTIVE", 'pending' => "PENDING", 'canceled' => "CANCELED",
                  'deactivated' => "DEACTIVATED", 'reactivating' => "REACTIVATING" }

  field :plan_id, type: String, pre_processed: true, default: ->{ Rails.configuration.billing[:default_plan] }
  field :plan_state, type: Array, pre_processed: true, default: ->{ PLAN_STATES['active'] }

  #def initialize(login=nil, ssh=nil, ssh_type=nil, key_name=nil, capabilities=nil, parent_user_login=nil)
  #  initialize_old(login, ssh, ssh_type, key_name, capabilities, parent_user_login)
  #end

  def get_plan_info(plan_id)
    plan_id = plan_id.to_s.downcase.to_sym if plan_id
    OpenShift::BillingService.instance.get_plans[plan_id] or
      raise OpenShift::UserException.new("A plan with specified id does not exist", 150, "plan_id")
  end

  def match_plan_capabilities(plan_id)
    plan_info = get_plan_info(plan_id)
    plan_caps = plan_info[:capabilities]
    caps = self.capabilities.deep_dup

    if plan_caps.has_key?("max_gears") && (plan_caps["max_gears"] != caps["max_gears"])
      raise OpenShift::UserException.new("User #{self.login} has gear limit set to #{caps["max_gears"]} but '#{plan_id}' plan allows #{plan_caps["max_gears"]}.", 160)
    end

    if plan_caps.has_key?("gear_sizes")
      if !caps.has_key?("gear_sizes")
        raise OpenShift::UserException.new("User #{self.login} does not have 'gear_sizes' capability provided by '#{plan_id}' plan", 182)
      elsif plan_caps["gear_sizes"].sort != caps["gear_sizes"].sort
        raise OpenShift::UserException.new("User #{self.login} can use gear sizes [#{caps["gear_sizes"].join(",")}] but '#{plan_id}' plan allows [#{plan_caps["gear_sizes"].join(",")}].", 161)
      end
    end

    if plan_caps.has_key?("max_untracked_addtl_storage_per_gear")
      if !caps.has_key?("max_untracked_addtl_storage_per_gear")
        raise OpenShift::UserException.new("User #{self.login} does not have 'max_untracked_addtl_storage_per_gear' capability provided by '#{plan_id}' plan", 183)
      elsif plan_caps["max_untracked_addtl_storage_per_gear"] != caps["max_untracked_addtl_storage_per_gear"]
        raise OpenShift::UserException.new("User #{self.login} has untracked additional file-system storage of #{caps["max_untracked_addtl_storage_per_gear"]} GB per gear but '#{plan_id}' plan allows #{plan_caps["max_untracked_addtl_storage_per_gear"]} GB.", 162)
      end
    end
    if plan_caps.has_key?("max_tracked_addtl_storage_per_gear")
      if !caps.has_key?("max_tracked_addtl_storage_per_gear")
        raise OpenShift::UserException.new("User #{self.login} does not have 'max_tracked_addtl_storage_per_gear' capability provided by '#{plan_id}' plan", 184)
      elsif plan_caps["max_tracked_addtl_storage_per_gear"] != caps["max_tracked_addtl_storage_per_gear"]
        raise OpenShift::UserException.new("User #{self.login} has tracked additional file-system storage of #{caps["max_tracked_addtl_storage_per_gear"]} GB per gear but '#{plan_id}' plan allows #{plan_caps["max_tracked_addtl_storage_per_gear"]} GB.", 181)
      end
    end
  end

  def check_plan_compatibility(plan_id)
    plan_info = get_plan_info(plan_id)
    plan_caps = plan_info[:capabilities]

    if plan_caps.has_key?("max_gears") && (plan_caps["max_gears"] < self.consumed_gears)
      raise OpenShift::UserException.new("User #{self.login} has more consumed gears(#{self.consumed_gears}) than the '#{plan_id}' plan allows.", 153)
    end
    if plan_caps.has_key?("gear_sizes")
      self.domains.each do |domain|
        domain.applications.each do |app|
          app.group_instances.uniq.each do |ginst|
            if !plan_caps["gear_sizes"].include?(ginst.gear_size)
              raise OpenShift::UserException.new("User #{self.login}, application '#{app.name}' has '#{ginst.gear_size}' type gear that the '#{plan_id}' plan does not allow.", 154)
            end
          end if app.group_instances
        end if domain.applications
      end if self.domains
    end
    addtl_storage = (plan_caps["max_untracked_addtl_storage_per_gear"] || 0) + (plan_caps["max_tracked_addtl_storage_per_gear"] || 0)
    self.domains.each do |domain|
      domain.applications.each do |app|
        app.group_instances.uniq.each do |ginst|
          if ginst.addtl_fs_gb && (ginst.addtl_fs_gb > addtl_storage)
            carts = ginst.all_component_instances.map{ |c| c.to_hash["cart"] }
            raise OpenShift::UserException.new("User #{self.login}, application '#{app.name}', gears having [#{carts.join(",")}] components has additional file-system storage of #{ginst.addtl_fs_gb} GB that the '#{plan_id}' plan does not allow.", 159)
          end
        end if app.group_instances
      end if domain.applications
    end if self.domains
       
    allow_certs = (plan_caps.has_key?("private_ssl_certificates") and plan_caps["private_ssl_certificates"] == true)

    self.domains.each do |domain|
      domain.applications.each do |app|
        app.aliases.each do |a|
          if a.has_private_ssl_certificate
            raise OpenShift::UserException.new("User #{self.login}, application '#{app.name}', alias #{a.fqdn} has private SSL certificate installed.  The '#{plan_id}' plan does not allow private SSL certificates.", 176)
          end
        end if app.aliases
      end if domain.applications
    end if self.domains and !allow_certs
    
  end

  def assign_plan(plan_id, persist=false)
    plan_info = get_plan_info(plan_id)
    self.capabilities = self.capabilities.
      slice(*PRESERVE_CAPABILITIES_ON_PLAN_CHANGE).
      reverse_merge!(plan_info[:capabilities])

    self.plan_id = plan_id
    self.save! if persist
  end

  alias_method :original_default_capabilities, :default_capabilities
  def default_capabilities
    if plan_id
      original_default_capabilities.merge!((get_plan_info(plan_id)[:capabilities] rescue {}))
    else
      original_default_capabilities
    end
  end

  def get_billing_account_no
    if self.usage_account_id
      return self.usage_account_id
    else
      billing_api = OpenShift::BillingService.instance
      billing_user_id = Digest::MD5::hexdigest(self.login)
      account_no = nil
      begin
        account_no = billing_api.get_acct_no_from_user_id(billing_user_id)
      rescue Exception => ex
        raise OpenShift::UserException.new("Could not get billing account number for user #{self.login} : #{ex.message}", 155)
      end
      raise OpenShift::UserException.new("Billing account not found", 151) if account_no.nil?
      return account_no
    end
  end

  def get_billing_details
    begin
      billing_api = OpenShift::BillingService.instance
      return billing_api.get_acct_details_all(self.get_billing_account_no)
    rescue Exception => ex
      raise OpenShift::UserException.new("Could not get billing account info for user #{self.login} : #{ex.message}", 155)
    end
  end

  def update_plan(plan_id, skip_lock=false)
    plan_info = self.get_plan_info(plan_id)

    cur_time = Time.now.utc
    filter = {:_id => self._id, :pending_plan_id => nil, :pending_plan_uptime => nil, "$or" => [{:plan_state => nil}, {:plan_state => PLAN_STATES['active']}]}
    update = {"$set" => {:pending_plan_id => plan_id, :pending_plan_uptime => cur_time, :plan_state => CloudUser::PLAN_STATES['pending']}}
    user = CloudUser.where(filter).find_and_modify(update, {:new => true})

    # Only rhc-admin-ctl-plan script skips the lock to fix user plans
    raise OpenShift::UserException.new("Plan change is not allowed at this time for this account. "\
          "Please retry after sometime and if problem persists, contact Red Hat support.", 221) unless user or skip_lock

    old_plan_id = nil
    old_capabilities = nil
    plan_upgrade = nil
    begin
      self.reload

      #check if subaccount user
      raise OpenShift::UserException.new("Plan change not allowed for subaccount user", 157) unless self.parent_user_id.nil?
      raise OpenShift::UserException.new("Plan change is not allowed for this account", 220) unless self.capabilities['plan_upgrade_enabled']

      #check to see if user can be switched to the new plan
      self.check_plan_compatibility(plan_id)

      #get billing account number and account details
      self.usage_account_id = self.get_billing_account_no unless self.usage_account_id
      account = self.get_billing_details

      default_plan_id = Rails.application.config.billing[:default_plan].to_s
      #allow user to downgrade to default plan if the a/c status is not active. 
      raise OpenShift::UserException.new("Billing account status not active", 152) if account["status_cd"].to_i <= 0 and plan_id != default_plan_id

      old_plan_id = self.plan_id
      old_capabilities = self.capabilities.dup
      #to minimize the window where the user can create gears without being on silver plan
      self.assign_plan(default_plan_id) if old_plan_id && (old_plan_id != default_plan_id)
      self.save!

      billing_api = OpenShift::BillingService.instance

      if account["plan_no"].to_i == plan_info[:plan_no]
        billing_api.cancel_queued_service_plan(self.usage_account_id)
        # This can only happen during plan upgrade
        plan_upgrade = true
      else
        cur_plan_index = -1
        new_plan_index = -1
        billing_api.get_plans.each_with_index do |plan, index|
          new_plan_index = index if plan[1][:plan_no] == plan_info[:plan_no]
          cur_plan_index = index if plan[0].to_s == old_plan_id
        end
        plan_upgrade = (new_plan_index > cur_plan_index)
        # Update plan in billing vendor
        billing_api.update_master_plan(self.usage_account_id, plan_id.to_sym, plan_upgrade)
      end
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.inspect
      raise
    ensure
      self.pending_plan_id = nil
      self.pending_plan_uptime = nil
      self.plan_state = CloudUser::PLAN_STATES['active']
      self.plan_id = old_plan_id if old_plan_id
      self.capabilities = old_capabilities if old_capabilities
      self.save!
    end

    #update user record
    self.pending_plan_id = nil
    self.pending_plan_uptime = nil
    self.plan_state = CloudUser::PLAN_STATES['active']
    if plan_upgrade
      old_plan_end_time = cur_time
    else
      cur_month_days = (Date.new(cur_time.year, 12, 31) << (12-cur_time.month)).day
      old_plan_end_time = Time.new(cur_time.year, cur_time.month, cur_month_days, 23, 59, 59)
    end
    self.plan_history.push({'plan_id' => old_plan_id, 'end_time' => old_plan_end_time})
    self.assign_plan(plan_id, true)
    
    # Update domain gear sizes
    begin
      domains.each do |d|
        d.allowed_gear_sizes = allowed_gear_sizes
        Rails.logger.error "Unable to update gear sizes for domain #{d.namespace} owned by user #{login} - #{d.errors.inspect}" if !d.save
      end
    rescue
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.inspect
    end

    # Revoke/Assign entitlements
    begin
      if old_plan_id != plan_id
        billing_service = OpenShift::BillingService.instance
        if billing_service.respond_to?('send_entitlements')
          old_plan_name = self.get_plan_info(old_plan_id)[:name]
          new_plan_name = plan_info[:name]
          tid = "T" + OpenShift::Counter.get_next_sequence("billing_transaction_id").to_s
          comment = "TransactionID: #{tid} - Plan changed from '#{old_plan_name}' to '#{new_plan_name}' on #{cur_time}"
          billing_service.write_acct_comment(self.usage_account_id, comment)
          billing_service.send_entitlements(self.login, self.usage_account_id, old_plan_name, new_plan_name, old_plan_end_time, tid)
        end
      end
    rescue Exception => e
      #Any entitlement failure should not cause user update failure
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.inspect
    end
  end
end
