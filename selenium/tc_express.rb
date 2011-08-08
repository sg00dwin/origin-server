#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Express < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  # Check express page links
  def test_check_express_links
    $logger.info "Testing express page links"
    goto_home
    goto_express
    
    find_element(:xpath, ".//li/a[@href='#videos']").click()
    check_title "OpenShift by Red Hat | Express"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='#about']").click()
    check_title "OpenShift by Red Hat | Express"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='https://docs.redhat.com/docs/en-US/OpenShift_Express/1.0/html/User_Guide/index.html']").click()
    check_title "User Guide"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='http://www.redhat.com/openshift/forums/express']").click()
    check_title "Express | Red Hat Openshift Forum"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='/app/user/new/express']").click()
    check_title "OpenShift by Red Hat | Sign up for OpenShift"
    @driver.navigate.back
    
    login("allaccess+test@redhat.com", "123456")
    
    find_element(:xpath, ".//li/a[@href='#quickstart']").click()
    check_title "OpenShift by Red Hat | Express"
    @driver.navigate.back
    
    check_element_displayed(:xpath, ".//li/a[@href='/app/dashboard']")

    @driver.save_screenshot('express.png')
  end

end
