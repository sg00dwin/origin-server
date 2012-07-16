class UserExtController < UserController
  include PlanHelper
  respond_to :xml, :json
  before_filter :authenticate, :check_version

  def update 
    # check to see if user exists
    if(@cloud_user.nil?)
      log_action(@request_id, 'nil', @login, "UPDATE_USER", false, "User '#{@login}' not found")
      @reply = RestReply.new(:not_found)
      @reply.messages.push(message = Message.new(:error, "User not found.", 99))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    plan_id = params[:plan_id]
    if not plan_id
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Plan #{plan_id} not found.")
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(message = Message.new(:error, "A plan with specified id does not exist", 150, "plan_id"))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    else
      plan_id = plan_id.downcase
    end
    new_plan = nil 
    #find requested plan
    Express::AriaBilling::Plan.instance.plans.each do |key, value|
      if key == plan_id.downcase
        new_plan = value
      end
    end
    if new_plan.nil?
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Plan #{plan_id} not found.")
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(message = Message.new(:error, "A plan with specified id does not exist", 150, "plan_id"))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    #check to see if user can be switched to the new plan
    if new_plan[:max_gears] < @cloud_user.consumed_gears
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login,"UPDATE_USER", false, "User '#{@login}' has more consumed gears than the new plan allows.")
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(message = Message.new(:error, "User has more consumed gears than the new plan allows.", 153))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    applications = @cloud_user.applications
    applications.each do |app|
      if app.node_profile != "small"
        log_action(@request_id, @cloud_user.uuid, @cloud_user.login,"UPDATE_USER", false, "User '#{@login}' has gears that the new plan does not allow.")
        @reply = RestReply.new(:unprocessable_entity)
        @reply.messages.push(message = Message.new(:error, "User has gears that the new plan does not allow.", 154))
        respond_with(@reply) do |format|
          format.xml { render :xml => @reply, :status => @reply.status }
          format.json { render :json => @reply, :status => @reply.status }
        end
        return
      end
    end
    aria = Express::AriaBilling::Api.instance
    user_id = Digest::MD5::hexdigest(@login)
    account_no = nil
    begin
      account_no = aria.get_acct_no_from_user_id(user_id)
    rescue Exception => ex
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Could not get account number for user #{ex.message}")
      @reply = RestReply.new( :not_found)
      @reply.messages.push(Message.new(:error, "Could not get account number for user #{ex.message}", 155))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    if account_no.nil?
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Account for user '#{@login}' not found")
      @reply = RestReply.new( :not_found)
      @reply.messages.push(Message.new(:error, "Account not found", 151))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    #get account details
    account = nil
    begin
      account = aria.get_acct_details_all(account_no)
    rescue
      rescue Exception => ex
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "Could not get account info for user #{ex.message}")
      @reply = RestReply.new( :not_found)
      @reply.messages.push(Message.new(:error, "Could not get account info for user #{ex.message}", 155))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
   
    if account["status_cd"].to_i <= 0 and plan_id != :freeshift
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, "User #{@login} account status #{account["status_cd"]} <= 0")
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(message = Message.new(:error, "Account status not active", 152))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    old_plan_id = @cloud_user.plan_id || :freeshift
    old_max_gears= @cloud_user.max_gears
    @cloud_user.plan_id = "#{old_plan_id}-to-#{plan_id}"
    #to minimize the window where the user can create gears without being on megashift plan
    if old_plan_id == :megashift
      @cloud_user.max_gears = Rails.configuration.ss[:default_max_gears]
    end
    @cloud_user.save
    begin 
      aria.update_master_plan(account_no, new_plan["name"])
      @cloud_user.plan_id = plan_id
      @cloud_user.max_gears = new_plan[:max_gears] 
      @cloud_user.save
    rescue Exception => e
      @cloud_user.plan_id = old_plan_id
      @cloud_user.max_gears = old_max_gears
      @cloud_user.save
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, e.message, 156))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
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