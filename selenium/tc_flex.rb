#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Flex < Test::Unit::TestCase
  include ::OpenShift::TestBase

  # Check Flex links
  def test_check_flex_links
    $logger.info "Testing flex links"
    goto_home
    goto_express
    goto_flex
    
    find_element(:xpath, ".//li/a[@href='#videos']").click()
    check_title "OpenShift by Red Hat | Flex"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='#about']").click()
    check_title "OpenShift by Red Hat | Flex"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='http://docs.redhat.com/docs/en-US/OpenShift_Flex/1.0/html/User_Guide/index.html']").click()
    check_title "User Guide"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='http://www.redhat.com/openshift/forums/flex']").click()
    check_title "Flex | Red Hat Openshift Forum"
    @driver.navigate.back

    find_element(:xpath, ".//li/a[@href='/app/user/new/flex']").click()
    check_title "OpenShift by Red Hat | Sign up for OpenShift"
    @driver.navigate.back
    
    login("allaccess+test@redhat.com", "123456")
    
    find_element(:xpath, ".//li/a[@href='#quickstart']").click()
    check_title "OpenShift by Red Hat | Flex"
    @driver.navigate.back
    
    check_element_displayed(:xpath, ".//li/a[@href='/flex']")

    @driver.save_screenshot('flex.png')
  end

end
