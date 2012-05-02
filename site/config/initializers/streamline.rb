require 'streamline/railties/controller_runtime'
require 'streamline/log_subscriber'

ActiveSupport.on_load(:action_controller) do
  include Streamline::Railties::ControllerRuntime
end

Streamline::LogSubscriber.attach_to :streamline
