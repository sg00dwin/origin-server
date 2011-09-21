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
    [
      {:pass => 19861231, 
        :err => 'Invalid email address'},
      {:email => '123', :pass => '19861231', 
        :err =>'Invalid email address'},
      {:email => "xtian+c0@redhat.com", 
        :err => 'Passwords must be at least 6 characters'},
      {:email => 'xtian+c0@redhat.com', :pass => '1986', 
        :err => 'Passwords must be at least 6 characters'},
      {:email => 'xtian+c0@redhat.com', :pass => '19861231', :confirm => '19861233', 
        :err => 'Passwords must match' },
      {:email => 'xyz@yahoo.ir', :pass => 'redhat', 
        :err => 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'}
    ].each do |hash|
      $logger.info "Testing register: #{hash[:err]}"
      submit_register(hash[:email], hash[:pass], hash[:confirm])
      check_element_displayed(:xpath, ".//div[@class='message error']//div[text()='#{hash[:err]}']")
      screenshot(hash[:err])
    end
    
    $logger.info "Testing register success"
    submit_register(get_unique_username(), "redhat")
    check_element_value("Check your inbox for an email with a validation link. Click on the link to complete the registration process." , :xpath, ".//section[@class='main']/div[@class='content']/p")
    screenshot('success')
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
