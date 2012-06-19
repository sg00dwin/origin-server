ENV["RAILS_ENV"] = "development"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

def gen_uuid
  %x[/usr/bin/uuidgen].gsub('-', '').strip 
end
