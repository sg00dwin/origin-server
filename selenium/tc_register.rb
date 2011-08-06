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
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys("123")
    find_element(:id,"web_user_password").send_keys("19861231")
    find_element(:id,"web_user_password_confirmation").send_keys("19861231")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "Please enter a valid email address.", find_element(:xpath,".//li[@id='web_user_email_address_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  def test_register_without_email
    $logger.info "start to test register without email"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_password").send_keys("19861231")
    find_element(:id,"web_user_password_confirmation").send_keys("19861231")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "This field is required.", find_element(:xpath,".//li[@id='web_user_email_address_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  def test_register_without_password
    $logger.info "start to test register without password"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "This field is required.", find_element(:xpath,".//li[@id='web_user_password_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  #Register with mismatching password
  def test_register_withmismatch_password
    $logger.info "start to test register with mismatching password"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")
    find_element(:id,"web_user_password").send_keys("19861231")
    find_element(:id,"web_user_password_confirmation").send_keys("19861233")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "Please enter the same value again.",find_element(:xpath,".//li[@id='web_user_password_confirmation_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  def test_register_with_invalid_passwd_length
    $logger.info "start to test register with invalid password length"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys("xtian+c0@redhat.com")
    find_element(:id,"web_user_password").send_keys("1986")
    find_element(:id,"web_user_password_confirmation").send_keys("1986")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "Please enter at least 6 characters.", find_element(:xpath,".//li[@id='web_user_password_input']/label[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  def test_register_with_restricted_country
    $logger.info "start to test register from restricted countries"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys("xyz@yahoo.ir")
    find_element(:id,"web_user_password").send_keys("redhat")
    find_element(:id,"web_user_password_confirmation").send_keys("redhat")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy", find_element(:xpath,".//li[@id='web_user_email_address_input']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  def test_register_normally
    $logger.info "start to test register normally"
    goto_home
    goto_login
    find_element(:link_text,"Click here to register").click()
    begin
      assert_equal "Register for access to Express", find_element(:xpath,".//div[@id='registration']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:id,"web_user_email_address").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:id,"web_user_email_address").send_keys(get_unique_username())
    find_element(:id,"web_user_password").send_keys("redhat")
    find_element(:id,"web_user_password_confirmation").send_keys("redhat")
    find_element(:id,"web_user_submit").click()
    begin
      assert_equal "Check your inbox for an email with a validation link. Click on the link to complete the registration process." , find_element(:xpath,".//div[@id='page']/div[2]/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end
end
