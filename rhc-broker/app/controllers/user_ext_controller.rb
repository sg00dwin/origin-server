class UserExtController < UserController
  action_log_tag_resource :user

  # GET /user
  def show
    user = get_rest_user(@cloud_user)
    user.plan_id = Rails.application.config.billing[:default_plan].to_s unless user.plan_id
    render_success(:ok, "user", user)
  end

  # PUT /user
  def update 
    begin
      @cloud_user.update_plan(params[:plan_id])
    rescue Exception => e
      return render_exception(e)
    end
    render_success(:ok, "account", get_rest_user(@cloud_user), "Plan successfully changed")
  end
end
