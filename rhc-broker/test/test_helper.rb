require File.expand_path('../coverage_helper.rb', __FILE__)

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'

def gen_uuid
  %x[/usr/bin/uuidgen].gsub('-', '').strip 
end

require 'active_support/test_case'
class ActiveSupport::TestCase
  setup{ Mongoid.identity_map_enabled = false }
end

require 'action_controller/test_case'
class ActionController::TestCase
  #
  # Clear all instance variables not set by rails before
  # a request is executed
  #
  def allow_multiple_execution(c=@controller)
    e = c.instance_eval{ class << self; self; end }
    e.send(:define_method, :reset_instance_variables) do
      instance_variables.select{ |sym| sym.to_s =~ /\A@[^_]/ }.each{ |sym| instance_variable_set(sym, nil) }
    end
    e.prepend_before_filter :reset_instance_variables
    c
  end
end

def stubber
  @container = OpenShift::ApplicationContainerProxy.find_one
  @container.stubs(:reserve_uid).returns(555)
  @container.stubs(:unreserve_uid)
  @container.stubs(:restart).returns(ResultIO.new)
  @container.stubs(:reload).returns(ResultIO.new)
  @container.stubs(:stop).returns(ResultIO.new)
  @container.stubs(:force_stop).returns(ResultIO.new)
  @container.stubs(:start).returns(ResultIO.new)
  @container.stubs(:add_alias).returns(ResultIO.new)
  @container.stubs(:remove_alias).returns(ResultIO.new)
  @container.stubs(:add_ssl_cert).returns(ResultIO.new)
  @container.stubs(:remove_ssl_cert).returns(ResultIO.new)
  @container.stubs(:tidy).returns(ResultIO.new)
  @container.stubs(:threaddump).returns(ResultIO.new)
  @container.stubs(:create).returns(ResultIO.new)
  @container.stubs(:destroy).returns(ResultIO.new)
  @container.stubs(:update_namespace).returns(ResultIO.new)
  @container.stubs(:add_component).returns(ResultIO.new)
  @container.stubs(:post_configure_component).returns(ResultIO.new)
  @container.stubs(:remove_component).returns(ResultIO.new)
  @container.stubs(:get_public_hostname).returns("node_dns")
  @container.stubs(:set_quota).returns(ResultIO.new)
  @container.stubs(:set_user_env_vars).returns(ResultIO.new)
  @container.stubs(:unset_user_env_vars).returns(ResultIO.new)
  OpenShift::ApplicationContainerProxy.stubs(:execute_parallel_jobs)
  RemoteJob.stubs(:get_parallel_run_results)
  OpenShift::ApplicationContainerProxy.stubs(:find_available).returns(@container)
  OpenShift::ApplicationContainerProxy.stubs(:find_one).returns(@container)
  dns = mock()
  OpenShift::DnsService.stubs(:instance).returns(dns)
  dns.stubs(:register_application)
  dns.stubs(:deregister_application)
  dns.stubs(:publish)
  dns.stubs(:close)
  Gear.any_instance.stubs(:get_proxy).returns(@container)
  Gear.stubs(:base_filesystem_gb).returns(1)
  Gear.stubs(:get_gear_states).returns("")
end
