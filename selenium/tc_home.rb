#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Home < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  def test_check_home_navigation
    $logger.info "Testing home navigation"
    goto_home
    check_element_displayed(:xpath, ".//img[@alt='Red Hat']")
    check_element_value("Sign In", :class, "user")
    
    goto_express
    
    goto_flex
    @driver.navigate.back
    
    find_element(:class,"power").click()
    check_title "OpenShift by Red Hat | Power"
    goto_home
    
    find_element(:xpath,".//a[contains(text(),'Forum')]").click()
    check_title "Forums | Red Hat Openshift Forum"
    @driver.navigate.back
    
    find_element(:xpath,".//a[contains(text(),'Blog')]").click()
    check_title "Blogs | Red Hat Openshift Forum"
    @driver.navigate.back
    
    find_element(:xpath,".//a[contains(text(),'Partner Program')]").click()
    check_title "OpenShift by Red Hat | Meet Our Partners"
    @driver.navigate.back
    
    find_element(:xpath,".//a[contains(@href, '/app/legal')]").click()
    check_title "OpenShift by Red Hat | Terms and Conditions"
    @driver.navigate.back
    
    find_element(:xpath,".//a[contains(text(),'Privacy Policy')]").click()
    check_title "OpenShift by Red Hat | OpenShift Privacy Statement"
    @driver.navigate.back
    
    check_element_displayed(:xpath, ".//a[contains(text(),'Contact')]")
    
    find_element(:xpath,".//a[contains(text(),'Security')]").click()
    check_title "access.redhat.com | Security contacts and procedures"
    @driver.navigate.back
    
    find_element(:class,"sign_up").click()
    check_title "OpenShift by Red Hat | Sign up for OpenShift"
    @driver.navigate.back
    
    sleep 2
    @driver.save_screenshot('home.png')
  end

end
