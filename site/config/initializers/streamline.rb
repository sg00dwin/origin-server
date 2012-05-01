require 'streamline/railties/controller_runtime'

ActiveSupport.on_load(:action_controller) do
  include Streamline::Railties::ControllerRuntime
end

Streamline::LogSubscriber.attach_to :streamline
