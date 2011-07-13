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

  
  #Login normal
  def test_login_normal
    puts "start to test login normally "
    @driver.navigate.to @url+"/app"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    begin
        assert  @driver.find_element(:xpath,".//input[@id='login_input']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//input[@id='login_input']").send_keys("libra-test+1@redhat.com")
    @driver.find_element(:xpath,".//input[@id='pwd_input']").send_keys("redhat")
    @driver.find_element(:xpath,".//input[@value='Login']").click()
    sleep 3
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, '/app/logout')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end


#Login with cookie deleted
  def test_login_with_cookie_deleted
    puts "start to test login with cookie deleted"
    @driver.navigate.to @url+"/app"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    begin
        assert  @driver.find_element(:xpath,".//input[@id='login_input']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//input[@id='login_input']").send_keys("libra-test+1@redhat.com")
    @driver.find_element(:xpath,".//input[@id='pwd_input']").send_keys("redhat")
    @driver.find_element(:xpath,".//input[@value='Login']").click()
    sleep 3
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, '/app/logout')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, '/app/login')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end    
   end

end

  
