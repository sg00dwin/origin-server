class CartridgeInstance < Cloud::Sdk::UserModel
  attr_accessor :state, :profile, :cartridge, :component_instance, :cartridge_name
  
  state_machine :state, :initial => :not_created do
    event(:create) { transition :not_created => :creating }
    event(:create_complete) { transition :creating => :stopped }
    event(:create_error) { transition :creating => :destroying }
    event(:start) { transition :stopped => :starting }
    event(:start_error) { transition :starting => :stopped }
    event(:start_complete) { transition :starting => :running }
    event(:stop) { transition :running => :stopping }
    event(:stop_error) { transition :stopping => :running }
    event(:stop_complete) { transition :stopping => :stopped }
    event(:destroy) { transition :stopped => :destroying }
    event(:destroy_complete) { transition :destroying => :not_created }
  end
end