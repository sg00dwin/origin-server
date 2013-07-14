class UserExtController < UserController

  # GET /user
  def show
    user = get_rest_user(@cloud_user)
    user.plan_id = Rails.application.config.billing[:default_plan].to_s unless user.plan_id
    render_success(:ok, "user", user)
  end

  # PUT /user
  def update 
    @cloud_user.update_plan(params[:plan_id])

    render_success(:ok, "account", get_rest_user(@cloud_user), "Plan successfully changed")
  end
end
