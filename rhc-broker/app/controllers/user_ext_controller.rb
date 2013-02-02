class UserExtController < UserController
  respond_to :xml, :json
  before_filter :authenticate, :check_version

  # GET /user
  def show
    user = get_rest_user(@cloud_user)
    user.plan_id = Rails.application.config.billing[:aria][:default_plan].to_s unless user.plan_id
    render_success(:ok, "user", user, "SHOW_USER")
  end

  # PUT /user
  def update 
    begin
      @cloud_user.update_plan(params[:plan_id])
    rescue Exception => e
      return render_exception(e, "UPDATE_USER")
    end
    render_success(:ok, "account", get_rest_user(@cloud_user), "UPDATE_USER", "Plan successfully changed")
  end
end
