#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Login < Test::Unit::TestCase
  include ::OpenShift::TestBase 

  def test_login_normal
    $logger.info "start to test login normally "
    @driver.navigate.to @url+"/app"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    retry_on_no_elem do
      begin
          assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
    retry_on_no_elem do
      begin
          assert  @driver.find_element(:xpath,".//input[@id='login_input']").displayed?
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
    @driver.find_element(:xpath,".//input[@id='login_input']").send_keys("libra-test+1@redhat.com")
    @driver.find_element(:xpath,".//input[@id='pwd_input']").send_keys("redhat")
    @driver.find_element(:xpath,".//input[@value='Login']").click()
    retry_on_no_elem do
      begin
          assert @driver.find_element(:xpath,".//a[contains(@href, '/app/logout')]").displayed?
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
  end

  def test_login_with_cookie_deleted
    $logger.info "start to test login with cookie deleted"
    @driver.navigate.to @url+"/app"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    retry_on_no_elem do
      begin
          assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
    retry_on_no_elem do
      begin
          assert  @driver.find_element(:xpath,".//input[@id='login_input']").displayed?
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
    @driver.find_element(:xpath,".//input[@id='login_input']").send_keys("libra-test+1@redhat.com")
    @driver.find_element(:xpath,".//input[@id='pwd_input']").send_keys("redhat")
    @driver.find_element(:xpath,".//input[@value='Login']").click()
    retry_on_no_elem do
      begin
          assert @driver.find_element(:xpath,".//a[contains(@href, '/app/logout')]").displayed?
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
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
