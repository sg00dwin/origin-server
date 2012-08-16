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

    begin
      @cloud_user.update_plan(params[:plan_id])
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error e.backtrace
      log_action(@request_id, @cloud_user.uuid, @cloud_user.login, "UPDATE_USER", false, e.message)
      return throw_error(:unprocessable_entity, e.message, e.code) if e.kind_of?(StickShift::UserException)
      return throw_error(:internal_server_error, e.message, 156)
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
