class UserExtController < UserController
  respond_to :xml, :json
  before_filter :authenticate, :check_version

  # PUT /user
  def update 
    unless @cloud_user
      log_action(@request_id, 'nil', @login, "UPDATE_USER", false, "User '#{@login}' not found")
      return render_format_error(:not_found, "User not found", 99)
    end

    begin
      @cloud_user.update_plan(params[:plan_id])
    rescue Exception => e
      return render_format_exception(e, "UPDATE_USER")
    end
    render_format_success(:ok, "account", RestUser.new(@cloud_user, get_url),
                          "UPDATE_USER", "Plan successfully changed")
  end
end
