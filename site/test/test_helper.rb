require File.expand_path('../coverage_helper.rb', __FILE__)

ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment.rb",  __FILE__)
require 'minitest/autorun'
require "rails/test_help"
require 'webmock/minitest'
WebMock.disable!

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{Console::Engine.root}/test/support/**/*.rb",
    "#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
