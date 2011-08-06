#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Home < Test::Unit::TestCase
  include ::OpenShift::TestBase
  def test_check_home_navigationbar
    $logger.info "Testing navigation bar"
    goto_home
    find_element(:class,"services").click()
    check_title "OpenShift by Red Hat | Express"
    find_element(:class,"flex").click()
    check_title "OpenShift by Red Hat | Flex"
    @driver.navigate.back
    find_element(:class,"power").click()
    check_title "OpenShift by Red Hat | Power"
    @driver.navigate.back
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Forum')]").click()
    check_title "Forums | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Blog')]").click()
    check_title "Blogs | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Partner Program')]").click()
    check_title "OpenShift by Red Hat | Meet Our Partners"
    @driver.navigate.back
    @driver.save_screenshot('navigation.png')
  end

  def test_check_home_links
    $logger.info "Testing home links"
    goto_home
    find_element(:class,"sign_up").click()
    check_title "OpenShift by Red Hat | Sign up for OpenShift"
    @driver.navigate.back
    @driver.save_screenshot('home_link.png')
  end

  def test_check_home_contents
    $logger.info "Testing home contents"
    goto_home
    check_element_value("Sign In", :class, "user")
    @driver.save_screenshot('home_content.png')
  end

  def test_check_home_footer
    $logger.info "Testing home footer"
    goto_home
    check_element_displayed(:xpath, ".//img[@alt='Red Hat']")
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
    sleep 2
    @driver.save_screenshot('home_footer.png')
  end
end
