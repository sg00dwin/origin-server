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

