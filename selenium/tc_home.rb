#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Home < Test::Unit::TestCase
  include ::OpenShift::TestBase 

  def test_check_home_navigationbar
    $logger.info "start to test navigation bar"
    @driver.navigate.to @url+"/app/"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat" , @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:class,"services").click()
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat | Express", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    retry_on_no_elem do
      @driver.find_element(:class,"flex").click()
    end
    begin
        assert_equal "OpenShift by Red Hat | Flex", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    retry_on_no_elem do
      @driver.find_element(:class,"power").click()
    end
    begin
        assert_equal "OpenShift by Red Hat | Power", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.navigate.back
    @driver.find_element(:xpath,".//a[contains(text(),'Forum')]").click()
    sleep 1
    begin
        assert_equal "Forums | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath,".//a[contains(text(),'Blog')]").click()
    sleep 1
    begin
        assert_equal "Blogs | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath,".//a[contains(text(),'Partner Program')]").click()
    sleep 1
    begin
        assert_equal "OpenShift by Red Hat | Meet Our Partners", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.save_screenshot('navigation.png')
  end

  def test_check_home_links
    $logger.info "start to test home links "
    @driver.navigate.to @url+"/app/"
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    retry_on_no_elem do
      @driver.find_element(:class,"sign_up").click()
    end
    begin
        assert_equal "OpenShift by Red Hat | Sign up for OpenShift", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.save_screenshot('home_link.png')
  end

  def test_check_home_contents
    $logger.info "start to check home contents"
    @driver.navigate.to @url+"/app/"
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Sign In", @driver.find_element(:class,"user").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.save_screenshot('home_content.png')
  end
   
  def test_check_home_footer
    $logger.info "start to check home footer"
    @driver.navigate.to @url+"/app/"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert  @driver.find_element(:xpath,".//img[@alt='Red Hat']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(@href, '/app/legal')]").click()
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat | Terms and Conditions", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    retry_on_no_elem do
      @driver.find_element(:xpath,".//a[contains(text(),'Privacy Policy')]").click()
    end
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat | OpenShift Privacy Statement", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    retry_on_no_elem do
      begin
          assert @driver.find_element(:xpath,".//a[contains(text(),'Contact')]").displayed?
      rescue Test::Unit::AssertionFailedError
          @verification_errors << $!
      end
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Security')]").click()
    sleep 2
    begin
        assert_equal "access.redhat.com | Security contacts and procedures", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    @driver.save_screenshot('home_footer.png')
  end
end
