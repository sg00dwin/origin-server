#!/usr/bin/env ruby
require "rubygems"
require "test/unit"
require 'selenium-webdriver'
require 'headless'
require 'logger'
require 'timeout'

# Setup the logger
$logger = Logger.new("/tmp/rhc/selenium.log")
$logger.level = Logger::DEBUG
$logger.formatter = proc do |severity, datetime, progname, msg|
    "#{$$} #{severity} #{datetime}: #{msg}\n"
end

module OpenShift
  module TestBase
    def setup
      @url="http://localhost"
      @verification_errors = []

      # Get a stable firefox connection
      10.times do
        begin
          Timeout::timeout(10) do
            @headless = Headless.new
            @headless.start
            @driver=Selenium::WebDriver.for :firefox
            @driver.manage.timeouts.implicit_wait = 5
          end
        rescue
          @headless.destroy
          $logger.warn "Firefox connection error.  Tearing down environment and retrying..."
        end
      end
    end

    def teardown
      @driver.quit if @driver
      @headless.destroy
      assert_equal [], @verification_errors
    end
  end
end

