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
    
    def retry_on_no_elem(retries=10)
      #wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
      #wait.until { yield }
      i = 0
      while true
        begin
          yield
          break
        rescue Selenium::WebDriver::Error::NoSuchElementError => e
          raise if i >= retries
          sleep 1
          i += 1
        end
      end
    end
    
    def setup
      @url="http://localhost"
      @verification_errors = []

      # Get a stable firefox connection
      10.times do
        begin
          Timeout::timeout(20) do
            @headless = Headless.new
            @headless.start
            @driver=Selenium::WebDriver.for :firefox
            @driver.manage.timeouts.implicit_wait = 10
            break
          end
        rescue Timeout::Error
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
    
    def goto_home
      @driver.navigate.to @url+"/app"
      check_title "OpenShift by Red Hat"
    end
    
    def goto_login
      find_element(:class,"sign_in").click()
      check_title "OpenShift by Red Hat | Sign in to OpenShift"
    end
    
    def login(username="libra-test+1@redhat.com", pwd="redhat")
      goto_home
      goto_login
      submit = nil
      begin
        submit = find_element(:xpath,".//input[@type='submit']") 
        assert submit.displayed?
      rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
      end
      find_element(:xpath,".//input[@id='login_input']").send_keys(username)
      find_element(:xpath,".//input[@id='pwd_input']").send_keys(pwd)
      submit.click()
      begin
        assert find_element(:xpath,".//a[contains(@href, '/app/logout')]").displayed?
      rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
      end
    end
    
    def check_title(title)
      begin
        assert_equal title, @driver.title
      rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
      end
    end
    
    def find_element(type, query)
      elem = nil
      retry_on_no_elem do
        elem = @driver.find_element(type, query)
      end
      return elem
    end
  end
end

