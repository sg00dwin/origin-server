require File.expand_path('./nurture', File.dirname(__FILE__))
require File.expand_path('./apptegic', File.dirname(__FILE__))
require 'openshift'

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
      alias_method :blacklisted_in_impl_old?, :blacklisted_in_impl?
    end

    def self.valid_gear_sizes_impl(user)
      default_gear_sizes = []
      capability_gear_sizes = []
      
      capability_gear_sizes = user.capabilities['gear_sizes'] if user.capabilities.has_key?('gear_sizes')

      if user.vip || user.auth_method == :broker_auth
        return ["small", "medium"] | capability_gear_sizes
      elsif !capability_gear_sizes.nil? and !capability_gear_sizes.empty?
        return capability_gear_sizes
      else
        return ["small"]
      end
    end

    def self.blacklisted_in_impl?(name)
      OpenShift::Blacklist.in_blacklist?(name)
    end


    def self.get_blacklisted_in_impl
      OpenShift::Blacklist.blacklist
    end
  end
end
