require 'simplecov'
SimpleCov.start 'rails' do
  coverage_dir 'test/coverage/'
  command_name ENV["TEST_NAME"] ||'RHC broker tests'
  add_filter 'test'
  merge_timeout 1000
end
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

def gen_uuid
  %x[/usr/bin/uuidgen].gsub('-', '').strip 
end
