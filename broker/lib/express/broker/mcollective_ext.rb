require File.expand_path('./nurture', File.dirname(__FILE__))
require File.expand_path('./apptegic', File.dirname(__FILE__))

module GearChanger
  class MCollectiveApplicationContainerProxy < StickShift::ApplicationContainerProxy
    alias :run_cartridge_command_old :run_cartridge_command

    def run_cartridge_command(framework, app, gear, command, arg=nil, allow_move=true)
      if allow_move
        Express::Broker::Nurture.application(app.user.login, app.user.uuid, app.name, app.domain.namespace, framework, command, app.uuid)
        Express::Broker::Apptegic.application(app.user.login, app.user.uuid, app.name, app.domain.namespace, framework, command, app.uuid)
      end
      run_cartridge_command_old(framework, app, gear, command, arg, allow_move)
    end

    class << self
      alias_method :valid_gear_sizes_impl_old, :valid_gear_sizes_impl
    end

    def self.valid_gear_sizes_impl(user)
      default_gear_sizes = [] 
      capability_gear_sizes = [] 
           
      if user.vip || user.auth_method == :broker_auth
        default_gear_sizes = ["small", "medium"]
      else 
        default_gear_sizes = ["small"]
      end  
           
      capability_gear_sizes = user.capabilities['gear_sizes'] if user.capabilities.has_key?('gear_sizes')
           
      if capability_gear_sizes.nil? or capability_gear_sizes.empty?
        return default_gear_sizes
      else 
        return capability_gear_sizes
      end  
    end 
  end
end
