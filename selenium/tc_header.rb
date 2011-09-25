#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Header < Test::Unit::TestCase
  include ::OpenShift::TestBase

  def test_header
    goto_home
    screenshot('header')
    # Make sure the logo is displayed
    check_element_displayed(:xpath, ".//img[@alt='Red Hat']")

    # Make sure the announcements are displayed
    check_element_displayed(:xpath, ".//aside[@id='announcements']")

    # Check links and their titles
    { 'Home' => 'OpenShift by Red Hat',
      'Cloud Services' => 'OpenShift by Red Hat | Express',
      'Community' => 'Forums | Red Hat Openshift Forum'
    }.each do |text,title|
      find_element(:xpath,".//a[text()='#{text}']").click()
      screenshot(text)
      check_title(title)
      @driver.navigate.back
    end

    # Make sure sign in link pops up form
    link = find_element(:xpath, ".//a[@class='sign_in']")
    if link
      check_element_value('Sign in',:xpath,".//a[@class='sign_in']")

      # Make sure sign in dialog is hidden, shows up, and hides again
      check_element_hidden(:xpath, ".//div[@id='signin']")
      link.click()
      check_element_displayed(:xpath, ".//div[@id='signin']")
      find_element(:xpath,".//div[@id='signin']//a[@class='close_button']").click()
      check_element_hidden(:xpath, ".//div[@id='signin']")
    end
  end
end
