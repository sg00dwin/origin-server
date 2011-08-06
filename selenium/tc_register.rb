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

  def test_register
    $logger.info "Testing register without email"
    submit_register(nil, "19861231")
    check_element_value("This field is required.", :xpath, ".//li[@id='web_user_email_address_input']/label[2]")

    $logger.info "Testing register with invalid email"
    submit_register("123", "19861231")
    check_element_value("Please enter a valid email address.", :xpath, ".//li[@id='web_user_email_address_input']/label[2]")

    $logger.info "Testing register without password"
    submit_register("xtian+c0@redhat.com", nil)
    check_element_value("This field is required.", :xpath, ".//li[@id='web_user_password_input']/label[2]")

    $logger.info "Testing register with invalid password length"    
    submit_register("xtian+c0@redhat.com", "1986")
    check_element_value("Please enter at least 6 characters.", :xpath, ".//li[@id='web_user_password_input']/label[2]")

    $logger.info "Testing register with mismatching password"
    submit_register("xtian+c0@redhat.com", "19861231", "19861233")
    check_element_value("Please enter the same value again.", :xpath, ".//li[@id='web_user_password_confirmation_input']/label[2]")
    
    $logger.info "Testing register from restricted countries"
    submit_register("xyz@yahoo.ir", "redhat")
    check_element_value("We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy", :xpath, ".//li[@id='web_user_email_address_input']/p")
    
    $logger.info "Testing register success"
    submit_register(get_unique_username(), "redhat")
    check_element_value("Check your inbox for an email with a validation link. Click on the link to complete the registration process." , :xpath, ".//section[@class='main']/div[@class='content']/p")
  end
  
  def submit_register(email, pwd, pwd_confirm=pwd)
    goto_home
    goto_login
    goto_register
    find_element(:id,"web_user_email_address").send_keys(email) if email
    find_element(:id,"web_user_password").send_keys(pwd) if pwd
    find_element(:id,"web_user_password_confirmation").send_keys(pwd_confirm) if pwd_confirm
    find_element(:id,"web_user_submit").click()
  end
end
