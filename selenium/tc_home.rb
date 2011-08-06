#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Home < Test::Unit::TestCase
  include ::OpenShift::TestBase
  def test_check_home_navigationbar
    $logger.info "start to test navigation bar"
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
    $logger.info "start to test home links"
    goto_home
    find_element(:class,"sign_up").click()
    check_title "OpenShift by Red Hat | Sign up for OpenShift"
    @driver.navigate.back
    @driver.save_screenshot('home_link.png')
  end

  def test_check_home_contents
    $logger.info "start to check home contents"
    goto_home
    begin
      assert_equal "Sign In", find_element(:class,"user").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.save_screenshot('home_content.png')
  end

  def test_check_home_footer
    $logger.info "start to check home footer"
    goto_home
    begin
      assert  find_element(:xpath,".//img[@alt='Red Hat']").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(@href, '/app/legal')]").click()
    check_title "OpenShift by Red Hat | Terms and Conditions"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Privacy Policy')]").click()
    check_title "OpenShift by Red Hat | OpenShift Privacy Statement"
    @driver.navigate.back
    begin
      assert find_element(:xpath,".//a[contains(text(),'Contact')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Security')]").click()
    check_title "access.redhat.com | Security contacts and procedures"
    @driver.navigate.back
    sleep 2
    @driver.save_screenshot('home_footer.png')
  end
end
