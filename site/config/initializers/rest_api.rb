require 'rest_api/railties/controller_runtime'
require 'rest_api/log_subscriber'

ActiveSupport.on_load(:action_controller) do
  include RestApi::Railties::ControllerRuntime
end

RestApi::LogSubscriber.attach_to :active_resource


ActiveSupport.on_load(:action_controller) do
  RestApi::Base.instantiate_observers
end
