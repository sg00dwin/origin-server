#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Home < Test::Unit::TestCase
  include ::OpenShift::TestBase 

  def test_check_home_navigationbar
    $logger.info "start to test  navigation bar"
    @driver.navigate.to @url+"/app/"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat" , @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:class,"express").click()
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat | Express", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:class,"flex").click()
    sleep 1
    begin
        assert_equal "OpenShift by Red Hat | Flex", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:class,"power").click()
    sleep 1
    begin
        assert_equal "OpenShift by Red Hat | Power", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='nav']/h5[2]").click() 
    @driver.find_element(:xpath,".//a[contains(text(),'Forums')]").click()
    sleep 1
    begin
        assert_equal "Forums | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:xpath,".//div[@id='nav']/h5[2]").click()
    @driver.find_element(:xpath,".//a[contains(text(),'Blog')]").click()
    sleep 1
    begin
        assert_equal "Blogs | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='nav']/h5[2]").click() 
    @driver.find_element(:xpath,".//a[contains(text(),'Partners')]").click()
    sleep 1
    begin
        assert_equal "OpenShift by Red Hat | Meet Our Partners", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:xpath,".//div[@id='nav']/h5[3]").click()
    @driver.find_element(:link_text,"KB").click()
    sleep 1
    begin
        assert_equal "Knowledge Base | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:xpath,".//div[@id='nav']/h5[3]").click()
    @driver.find_element(:xpath,".//a[contains(text(),'Docs')]").click()
    sleep 1
    begin
        assert_equal "Documents | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='nav']/h5[3]").click()
    @driver.find_element(:xpath,".//a[contains(text(),'Videos')]").click()
    sleep 1
    begin
        assert_equal "Videos | Red Hat Openshift Forum", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:xpath,".//div[@id='nav']/h5[3]").click()
    @driver.find_element(:xpath,".//a[contains(text(),'FAQ')]").click()
    sleep 1
    begin
        assert_equal "Frequently Asked Questions | Red Hat Openshift Forum", @driver.title
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
    sleep 5
    @driver.find_element(:class,"try_it").click()
    sleep 1
    begin
        assert_equal "TRY EXPRESS",@driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 1
    @driver.find_element(:xpath,".//div[@id='app_promos']").click()
    @driver.find_element(:xpath,".//div[@id='app_promos']/div[1]/div/ul/li[4]/a").click()
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='app_promos']").click()
    @driver.find_element(:xpath,".//div[@id='app_promos']/div[2]/div/ul/li[4]/a").click()
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='app_promos']").click()
    @driver.find_element(:xpath,".//div[@id='app_promos']/div[3]/div/ul/li[4]/a").click()
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
        assert_equal "LOGIN", @driver.find_element(:id,"login").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "TRY IT NOW!", @driver.find_element(:id,"button").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Deploy in Minutes", @driver.find_element(:xpath,".//div[@id='deploy_in_minutes']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Upload code and go! Whether you prefer a CLI or browser-based UI, OpenShift provides the fastest and easiest on-ramp to the cloud.", @driver.find_element(:xpath,".//div[@id='deploy_in_minutes']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Focus on your App,\nnot the Stack", @driver.find_element(:xpath,".//div[@id='focus_on_your_app']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "OpenShift supports and manages multiple frameworks, languages, middleware and clouds so you don't have to.", @driver.find_element(:xpath,".//div[@id='focus_on_your_app']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Auto-scale", @driver.find_element(:xpath,".//div[@id='auto_scale']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Take advantage of the elasticity of the cloud, regardless if your app was designed for it or not.", @driver.find_element(:xpath,".//div[@id='auto_scale']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert  @driver.find_element(:xpath,".//img[@id='front_image']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert  @driver.find_element(:xpath,".//div[@id='app_promos']").displayed?
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
    begin
        assert_equal "Copyright © 2011 Red Hat, Inc.",@driver.find_element(:xpath,".//div[@id='footer']/p").text
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
    begin
        assert_equal "LEGAL TERMS",@driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//a[contains(text(),'Privacy Policy')]").click()
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat | OpenShift Privacy Statement", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "PRIVACY STATEMENT",@driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    begin
        assert @driver.find_element(:xpath,".//a[contains(text(),'Contact Us')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Security')]").click()
    sleep 2
    begin
        assert_equal "access.redhat.com | Security contacts and procedures", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Security contacts and procedures",@driver.find_element(:xpath,".//div[@id='main']/h1").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    @driver.save_screenshot('home_footer.png')
  end
end
