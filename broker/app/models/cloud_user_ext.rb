class CloudUser < StickShift::UserModel
  alias :initialize_old :initialize

  def initialize(login=nil, ssh=nil, ssh_type=nil, key_name=nil, capabilities=nil, parent_user_login=nil)
    initialize_old(login, ssh, ssh_type, key_name, capabilities, parent_user_login)
  end

  def get_capabilities
    user_capabilities = self.capabilities.dup
    if self.parent_user_login
      parent_user = CloudUser.find(self.parent_user_login)
      parent_user.capabilities['inherit_on_subaccounts'].each do |cap|
        user_capabilities[cap] = parent_user.capabilities[cap] if parent_user.capabilities[cap] 
      end if parent_user && parent_user.capabilities.has_key?('inherit_on_subaccounts')
    end
    user_capabilities
  end

  def get_plan_info(plan_id)
    plan_id.downcase! if plan_id

    if !plan_id || !Express::AriaBilling::Plan.instance.valid_plan(plan_id)
      raise StickShift::UserException.new("A plan with specified id does not exist", 150, "plan_id")
    end
    Express::AriaBilling::Plan.instance.plans[plan_id.to_sym]
  end

  def match_plan_capabilities(plan_id)
    plan_info = get_plan_info(plan_id)
    capabilities = plan_info[:capabilities]

    if capabilities.has_key?("max_gears") && (capabilities["max_gears"] != self.max_gears)
      raise StickShift::UserException.new("User #{self.login} has gear limit set to #{self.max_gears} but '#{plan_id}' plan allows #{capabilities["max_gears"]}.", 160)
    end
    if capabilities.has_key?("gear_sizes") && self.capabilities.has_key?("gear_sizes") &&
       (capabilities["gear_sizes"].sort != self.capabilities["gear_sizes"].sort)
      raise StickShift::UserException.new("User #{self.login} can use gear sizes [#{self.capabilities["gear_sizes"].join(",")}] but '#{plan_id}' plan allows [#{capabilities["gear_sizes"].join(",")}].", 161)
    end
    if capabilities.has_key?("max_storage_per_gear") && self.capabilities.has_key?("max_storage_per_gear") &&
       (capabilities["max_storage_per_gear"] != self.capabilities["max_storage_per_gear"])
      raise StickShift::UserException.new("User #{self.login} can have additional file-system storage of #{self.capabilities["max_storage_per_gear"]} GB per gear group but '#{plan_id}' plan allows #{capabilities["max_storage_per_gear"]} GB.", 162)
    end
  end

  def check_plan_compatibility(plan_id)
    plan_info = get_plan_info(plan_id)
    capabilities = plan_info[:capabilities]

    if capabilities.has_key?("max_gears") && (capabilities["max_gears"] < self.consumed_gears)
      raise StickShift::UserException.new("User #{self.login} has more consumed gears(#{self.consumed_gears}) than the '#{plan_id}' plan allows.", 153)
    end
    if capabilities.has_key?("gear_sizes")
      self.applications.each do |app|
        if !capabilities["gear_sizes"].include?(app.node_profile)
          raise StickShift::UserException.new("User #{self.login}, application '#{app.name}' has '#{app.node_profile}' type gear that the '#{plan_id}' plan does not allow.", 154)
        end
      end if self.applications
    end
    addtl_storage = 0
    addtl_storage = capabilities["max_storage_per_gear"] if capabilities.has_key?("max_storage_per_gear")
    self.applications.each do |app|
      app.group_instances.uniq.each do |ginst|
        if ginst.addtl_fs_gb && (ginst.addtl_fs_gb > addtl_storage)
          carts = []
          carts = ginst.gears[0].cartridges if ginst.gears[0]
          raise StickShift::UserException.new("User #{self.login}, application '#{app.name}', gears having [#{carts.join(",")}] components has additional file-system storage of #{ginst.addtl_fs_gb} GB that the '#{plan_id}' plan does not allow.", 159)
        end
      end if app.group_instances
    end if self.applications
  end

  def assign_plan(plan_id, persist=false)
    plan_info = get_plan_info(plan_id)
    capabilities = plan_info[:capabilities]

    self.plan_id = plan_id
    self.capabilities_will_change!
    self.capabilities = capabilities.dup
    self.capabilities.delete('max_gears')
    self.max_gears = capabilities['max_gears'] if capabilities.has_key?('max_gears')
    self.save if persist
  end

  def get_billing_account_no
    if self.usage_account_id
      return self.usage_account_id
    else
      billing_api = Express::AriaBilling::Api.instance
      billing_user_id = Digest::MD5::hexdigest(self.login)
      account_no = nil
      begin
        account_no = billing_api.get_acct_no_from_user_id(billing_user_id)
      rescue Exception => ex
        raise StickShift::UserException.new("Could not get billing account number for user #{self.login} : #{ex.message}", 155)
      end
      raise StickShift::UserException.new("Billing account not found", 151) if account_no.nil?
      return account_no
    end
  end

  def get_billing_details
    begin
      billing_api = Express::AriaBilling::Api.instance
      return billing_api.get_acct_details_all(self.get_billing_account_no)
    rescue Exception => ex
      raise StickShift::UserException.new("Could not get billing account info for user #{self.login} : #{ex.message}", 155)
    end
  end

  def update_plan(plan_id)
    plan_info = self.get_plan_info(plan_id)

    #check if subaccount user
    raise StickShift::UserException.new("Plan change not allowed for subaccount user", 157) if self.parent_user_login

    #check to see if user can be switched to the new plan
    self.check_plan_compatibility(plan_id)

    #get billing account number and account details
    self.usage_account_id = self.get_billing_account_no unless self.usage_account_id
    account = self.get_billing_details

    default_plan_id = Rails.application.config.billing[:aria][:default_plan].to_s
    #allow user to downgrade to default plan if the a/c status is not active. 
    raise StickShift::UserException.new("Billing account status not active", 152) if account["status_cd"].to_i <= 0 and plan_id != default_plan_id

    old_plan_id = self.plan_id
    old_capabilities = self.capabilities
    old_max_gears = self.max_gears
    cur_time = Time.now.utc
    self.pending_plan_id = plan_id
    self.pending_plan_uptime = cur_time

    #to minimize the window where the user can create gears without being on megashift plan
    self.assign_plan(default_plan_id) if old_plan_id && (old_plan_id != default_plan_id)
    self.save

    billing_api = Express::AriaBilling::Api.instance
    begin
      #update plan in aria
      billing_api.update_master_plan(self.usage_account_id, plan_id.to_sym) unless plan_info[:plan_no] == account["plan_no"]
    rescue Exception => e
      self.pending_plan_id = nil
      self.pending_plan_uptime = nil
      self.plan_id = old_plan_id
      self.capabilities_will_change!
      self.capabilities = old_capabilities
      self.max_gears = old_max_gears
      self.save
      Rails.logger.error e
      raise
    end

    #update user record
    self.pending_plan_id = nil
    self.pending_plan_uptime = nil
    self.assign_plan(plan_id, true)

    begin
      #check user record consistency
      self.check_plan_compatibility(self.plan_id)
      self.match_plan_capabilities(self.plan_id)
    rescue Exception => e
      #update succeeded but the user record is in inconsistent state (can happen in case of parallel ops)
      # - assign default plan temporarily to restrict un-authorized resources
      # - put pending plan id marker so that it is fixed later by background process/ops team.
      self.pending_plan_id = plan_id
      self.pending_plan_uptime = cur_time
      self.assign_plan(default_plan_id, true)
      begin
        billing_api.update_master_plan(self.usage_account_id, default_plan_id.to_sym) if self.usage_account_id
      rescue
      end
      Rails.logger.error e
      raise
    end
  end
end
