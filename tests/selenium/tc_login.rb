#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'


class Login < Test::Unit::TestCase

  def setup
    @verification_errors = []
    @headless = Headless.new
    @headless.start
#    @profile = Selenium::WebDriver::Firefox::Profile.new
#    @proxy = Selenium::WebDriver::Proxy.new(:ssl => "file.sjc.redhat.com:3128")
#    @profile.proxy =@proxy
#    @driver=Selenium::WebDriver.for :firefox, :profile =>@profile
    @driver=Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 5
    @url="http://localhost"
  end
  
  def teardown
    @driver.quit
# Cleanup headless display
    @headless.destroy
    assert_equal [], @verification_errors
  end


  def test_normal_login
    puts "start to test login"
   @driver.navigate.to @url+"/app"
   @driver.find_element(:id, 'login').click()
   @driver.find_element(:id, 'login_input').send_keys('test@redhat.com')
   @pwd =@driver.find_element(:id, 'pwd_input')
   @pwd.send_keys('none')
   @pwd.submit()
    puts "Saving a screenshot"
   @driver.save_screenshot('logged_in.png')
  end
end

  
