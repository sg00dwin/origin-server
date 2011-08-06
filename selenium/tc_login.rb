#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Login < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  def test_login
    $logger.info "Testing login"
    login
    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    check_element_displayed(:xpath, ".//a[contains(@href, '/app/login')]")
  end
end
