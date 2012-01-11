class UserController < BaseController
  respond_to :html, :xml, :json
  before_filter :authenticate
  # GET /users/<id>
  def show
    id = params[:id]
    user = CloudUser.find(@login)
    if(user.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "User #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    @result = Result.new(:ok, "user", user)
    respond_with(@result, :status => :ok)
  end

end
