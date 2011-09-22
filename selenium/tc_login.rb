#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Login < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  def test_login
    $logger.info "Testing login"
    goto_home
    login
    screenshot('after login')
    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    screenshot('after refresh')
    check_element_displayed(:xpath,".//nav[@id='main_nav']//a[@class='sign_in']")
  end
end
