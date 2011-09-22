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
    screenshot('home')

    # Make sure sign up link pops up form
    [ "opener", "bottom_signup" ].each do |section|
      link = find_element(:xpath, ".//section[@id='#{section}']//a[text()='Sign up and try it']")
      # Make sure sign up dialog is hidden, shows up, and hides again
      signup = ".//div[@id='signup']"
      check_element_hidden(:xpath, signup)
      link.click()
      screenshot("#{section} signup dialog")
      check_element_displayed(:xpath, signup)
      find_element(:xpath,"#{signup}//a[@class='close_button']").click()
      check_element_hidden(:xpath, signup)
    end
 end
end
