#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Register < Test::Unit::TestCase
  include ::OpenShift::TestBase 

  def get_unique_username()
    chars =("1".."9").to_a
    useremail=  "libra-test+"+ Array.new(8, '').collect{chars[rand(chars.size)]}.join+"@redhat.com"
    return useremail
  end

  def test_register_invalid_email
    $logger.info "start to test register with invalid email "
    @driver.navigate.to @url+"/app"
    sleep 2
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys("123")
    @driver.find_element(:id,"web_user_password").send_keys("19861231")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("19861231")
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "Please enter a valid email address.", @driver.find_element(:xpath,".//li[@id='web_user_email_address_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_register_without_email
    $logger.info "start to test register without email"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_password").send_keys("19861231")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("19861231")
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "This field is required.",@driver.find_element(:xpath,".//li[@id='web_user_email_address_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_register_without_password
    $logger.info "start to test register without password"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")    
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "This field is required.",@driver.find_element(:xpath,".//li[@id='web_user_password_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

#Register with mismatching password
  def test_register_withmismatch_password
    $logger.info "start to test register with mismatching password"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")
    @driver.find_element(:id,"web_user_password").send_keys("19861231")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("19861233")   
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "Please enter the same value again.",@driver.find_element(:xpath,".//li[@id='web_user_password_confirmation_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_register_with_invalid_passwd_length
    $logger.info "start to test register with invalid password length"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")
    @driver.find_element(:id,"web_user_password").send_keys("1986")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("1986")   
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "Please enter at least 6 characters." ,@driver.find_element(:xpath,".//li[@id='web_user_password_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

  def test_register_with_restricted_country
    $logger.info "start to test register from restricted countries"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys("xyz@yahoo.ir")
    @driver.find_element(:id,"web_user_password").send_keys("redhat")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("redhat")   
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy" , @driver.find_element(:xpath,".//li[@id='web_user_email_address_input']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end   
  end
 
  def test_register_normally
    $logger.info "start to test register normally"    
    @driver.navigate.to @url+"/app"
    sleep 3
    begin
        assert_equal "OpenShift by Red Hat", @driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='login']/a").click()
    sleep 2
    begin
        assert_equal "LOGIN TO OPENSHIFT", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:link_text,"Click here to register").click()
    sleep 2
    begin
        assert_equal "Register for access to Express", @driver.find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:id,"web_user_email_address").send_keys(get_unique_username())
    @driver.find_element(:id,"web_user_password").send_keys("redhat")
    @driver.find_element(:id,"web_user_password_confirmation").send_keys("redhat")   
    @driver.find_element(:id,"web_user_submit").click()
    sleep 2
    begin
        assert_equal "Check your inbox for an email with a validation link. Click on the link to complete the registration process." , @driver.find_element(:xpath,".//div[@id='page']/div[2]/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end   
  end
end
