class UserExtController < UserController
  respond_to :xml, :json
  before_filter :authenticate, :check_version

  # PUT /user
  def update 
    #check to see if user exists
    if @cloud_user.nil?
      log_action(@request_id, 'nil', @login, "UPDATE_USER", false, "User '#{@login}' not found")
      return throw_error(:not_found, "User not found", 99)
    end

    #check if subaccount user
    if @cloud_user.parent_user_login
      log_action(@request_id, 'nil', @login, "UPDATE_USER", false, "Plan change not allowed for subaccount user '#{@login}'")
      return throw_error(:unprocessable_entity, "Plan change not allowed for subaccount user", 157)
    end
    
    plan_id = params[:plan_id]
    plan_id.downcase! if plan_id

    #find requested plan
    if !plan_id || !Express::AriaBilling::Plan.instance.valid_plan(plan_id)
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Plan #{plan_id} not found.")
      return throw_error(:unprocessable_entity, "A plan with specified id does not exist", 150, "plan_id")
    end
    new_plan = Express::AriaBilling::Plan.instance.plans[plan_id.to_sym]

    #check to see if user can be switched to the new plan
    if new_plan[:capabilities].has_key?("max_gears") && new_plan[:capabilities]["max_gears"] < @cloud_user.consumed_gears
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login,"UPDATE_USER", false, "User '#{@login}' has more consumed gears than the new plan allows.")
      return throw_error(:unprocessable_entity, "User has more consumed gears than the new plan allows.", 153)
    end
 
    found_invalid_gears = false
    if new_plan[:capabilities].has_key?("gear_sizes")
      @cloud_user.applications.each do |app|
        if not new_plan[:capabilities]["gear_sizes"].include?(app.node_profile)
          found_invalid_gears = true
          break
        end
      end if @cloud_user.applications
    end
    if found_invalid_gears
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login,"UPDATE_USER", false, "User '#{@login}' has gears that the new plan does not allow.")
      return throw_error(:unprocessable_entity, "User has gears that the new plan does not allow.", 154)
    end

    #get account number
    aria = Express::AriaBilling::Api.instance
    user_id = Digest::MD5::hexdigest(@login)
    account_no = @cloud_user.usage_account_id
    begin
      unless account_no
        account_no = aria.get_acct_no_from_user_id(user_id)
        @cloud_user.usage_account_id = account_no
      end
    rescue Exception => ex
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Could not get account number for user #{ex.message}")
      return throw_error(:not_found, "Could not get account number for user #{ex.message}", 155)
    end
    if account_no.nil?
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Account for user '#{@login}' not found")
      return throw_error(:not_found, "Account not found", 151)
    end

    #get account details
    account = nil
    begin
      account = aria.get_acct_details_all(account_no)
    rescue Exception => ex
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Could not get account info for user #{ex.message}")
      return throw_error(:not_found, "Could not get account info for user #{ex.message}", 155)
    end
 
    #allow user to downgrade to default plan if the a/c status is not active. 
    default_plan_id = Rails.application.config.billing[:aria][:default_plan].to_s
    if account["status_cd"].to_i <= 0 and plan_id != default_plan_id
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "User #{@login} account status #{account["status_cd"]} <= 0")
      return throw_error(:unprocessable_entity, "Account status not active", 152)
    end
    old_plan_id = @cloud_user.plan_id || default_plan_id
    old_capabilities = @cloud_user.capabilities
    old_max_gears = @cloud_user.max_gears
    @cloud_user.plan_id = "#{old_plan_id}-to-#{plan_id}"
    #to minimize the window where the user can create gears without being on megashift plan
    if old_plan_id != default_plan_id
      default_plan = Rails.application.config.billing[:aria][:plans][default_plan_id.to_sym]
      @cloud_user.capabilities = default_plan[:capabilities].dup
      @cloud_user.capabilities.delete('max_gears')
      @cloud_user.max_gears = default_plan[:capabilities]['max_gears'] if default_plan[:capabilities].has_key?('max_gears')
    end
    @cloud_user.save
    begin
      #update plan and user record 
      aria.update_master_plan(account_no, plan_id.to_sym) unless new_plan[:plan_no] == account["plan_no"]
      @cloud_user.plan_id = plan_id
      @cloud_user.capabilities = new_plan[:capabilities].dup
      if @cloud_user.capabilities.has_key?("max_gears")
        @cloud_user.max_gears = @cloud_user.capabilities["max_gears"]
        @cloud_user.capabilities.delete("max_gears")
      end
      @cloud_user.save

      #check user record consistency
      @cloud_user = CloudUser.find(@login)
      if @cloud_user.plan_id == plan_id
        if new_plan[:capabilities].has_key?("max_gears") && 
           ((new_plan[:capabilities]["max_gears"] != @cloud_user.max_gears) || (@cloud_user.max_gears < @cloud_user.consumed_gears))
          raise StickShift::UserException.new("User has more consumed gears than the new plan allows.", 153)
        elsif new_plan[:capabilities].has_key?("gear_sizes")
          @cloud_user.applications.each do |app|
            raise StickShift::UserException.new("User has gears that the new plan does not allow.", 154) if !new_plan[:capabilities]["gear_sizes"].include?(app.node_profile)
          end if @cloud_user.applications
        end
      end
    rescue Exception => e
      @cloud_user.plan_id = old_plan_id
      @cloud_user.capabilities = old_capabilities
      @cloud_user.max_gears = old_max_gears
      @cloud_user.save
      if e.class == StickShift::UserException
        return throw_error(:unprocessable_entity, e.message, e.code)
      else
        return throw_error(:internal_server_error, e.message, 156)
      end
    end
    
    log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER")
    @reply = RestReply.new(:ok, "account", RestUser.new(@cloud_user, get_url))
    @reply.messages.push(message = Message.new(:info, "Plan successfully changed"))
    respond_with(@reply) do |format|
      format.xml { render :xml => @reply, :status => @reply.status }
      format.json { render :json => @reply, :status => @reply.status }
    end
  end
end
