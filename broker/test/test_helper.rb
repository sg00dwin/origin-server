ENV["RAILS_ENV"] = "test"
$:.unshift(File.dirname(__FILE__) + '/../../server-common')
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'openshift'
