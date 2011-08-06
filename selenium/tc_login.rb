#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Login < Test::Unit::TestCase
  include ::OpenShift::TestBase
  def test_login_normal
    $logger.info "start to test login normally"
    login
  end

  def test_login_with_cookie_deleted
    $logger.info "start to test login with cookie deleted"
    login
    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    begin
      assert find_element(:xpath,".//a[contains(@href, '/app/login')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end
end
