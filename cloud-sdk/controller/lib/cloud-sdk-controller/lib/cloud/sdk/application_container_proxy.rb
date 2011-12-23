module Cloud
  module Sdk
    class ApplicationContainerProxy
      @proxy_provider = Cloud::Sdk::ApplicationContainerProxy
      
      def self.provider=(provider_class)
        @proxy_provider = provider_class
      end
      
      def self.instance(id)
        @proxy_provider.new(id)
      end
      
      def self.find_available(node_profile=nil)
        @proxy_provider.find_available_impl(node_profile)
      end
      
      attr_accessor :id
      def self.find_available_impl(node_profile=nil)
      end
      
      def initialize(id)
        @id = id
      end
      
      def get_available_cartridges(cart_type)
      end
      
      def create(app)
      end
    
      def destroy(app)
      end
      
      def add_authorized_ssh_key(app, ssh_key)
      end
      
      def remove_authorized_ssh_key(app, ssh_key)
      end
    
      def add_env_var(app, key, value)
      end
      
      def remove_env_var(app, key)
      end
    
      def add_broker_auth_key(app, id, token)
      end
    
      def remove_broker_auth_key(app)
      end
      
      def preconfigure_cartridge(app, cart)
      end
      
      def configure_cartridge(app, cart)
      end
      
      def deconfigure_cartridge(app, cart)
      end
      
      def get_public_hostname
      end
      
      def start(app, cart)
      end
      
      def stop(app, cart)
      end
      
      def force_stop(app, cart)
      end
      
      def restart(app, cart)
      end
      
      def reload(app, cart)
      end
      
      def status(app, cart)
      end
      
      def tidy(app, cart)
      end
      
      def threaddump(app, cart)
      end
      
      def add_alias(app, cart, server_alias)
      end
      
      def remove_alias(app, cart, server_alias)
      end
      
      def add_component(app, component)
      end
      
      def remove_component(app, component)
      end
      
      def start_component(app, component)
      end
      
      def stop_component(app, component)
      end
      
      def restart_component(app, component)
      end
      
      def reload_component(app, component)
      end
      
      def component_status(app, component)
      end
      
      def move_app(app, destination_container_proxy)
      end
      
      def update_namespace(app, cart, new_ns, old_ns)
      end
    end
  end
end