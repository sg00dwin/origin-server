class CartridgesController < ConsoleController

  def index
     # on index get, redirect back to application details page
     redirect_to application_path(params['application_id'])
  end

  def show
    @domain = Domain.find :one, :as => session_user
    @application = @domain.find_application params[:application_id]
    @application_type = ApplicationType.find @application.framework
    Rails.logger.debug @application.cartridges
    @cartridge = @application.find_cartridge params[:id]
  end

  def create
    cart_params = params[:cartridge]
    @domain = Domain.find :one, :as => session_user
    @application = @domain.find_application params[:application_id]
    # TODO: check for app errors and redirect to app list if error

    @cartridge = Cartridge.new cart_params

    @cartridge.application = @application
    @cartridge.as = session_user

    @cartridge_type = CartridgeType.find cart_params[:name], :as => session_user

    if @cartridge.save
      @wizard = true
      messages = @cartridge.attributes[:messages]
      @cartridge_message = ""

      unless messages.nil?
        result = messages.find { |m| m[:field] == "result" }
        @cartridge_message = result[:text] if result.respond_to?(:has_key?) && result.has_key?(:text)
      end

      render :next_steps
    else
      Rails.logger.debug @cartridge.errors.inspect
      @application_id = @application.id
      render 'cartridge_types/show'
    end
  end

  def next_steps
    @domain = Domain.find :one, :as => session_user
    @application = @domain.find_application params[:id]

    @wizard = !params[:wizard].nil?
  end
end

