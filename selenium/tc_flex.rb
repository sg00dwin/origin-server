#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Flex < Test::Unit::TestCase
  include ::OpenShift::TestBase

  # Check Flex links
  def test_check_public_flex_links
    $logger.info "Testing flex links"
    goto_home
    goto_flex
    screenshot('after goto flex')
    
    find_element(:xpath,".//a[@href='#about']").click()
    screenshot('About')
    check_title('OpenShift by Red Hat | Flex')
    @driver.navigate.back

    { 'Videos' => 'OpenShift by Red Hat | Flex',
      'Documentation' => 'User Guide',
      'Forum' => 'Flex | Red Hat Openshift Community'
    }.each do |text,title|
      find_element(:xpath,".//a[text()='#{text}']").click()
      screenshot(text)
      check_title(title)
      @driver.navigate.back
    end

    # Make sure sign in link pops up form
    link = find_element(:xpath, ".//a[text()='Sign up to try Flex!']")
    # Make sure sign in dialog is hidden, shows up, and hides again
    signup = ".//div[@id='signup']"
    check_element_hidden(:xpath, signup)
    link.click()
    screenshot('signup dialog')
    check_element_displayed(:xpath, signup)
    find_element(:xpath,"#{signup}//a[@class='close_button']").click()
    check_element_hidden(:xpath, signup)
  end
  

  def test_check_logged_in_flex_links
    goto_home
    goto_flex
    login("allaccess+test@redhat.com", "123456")
    screenshot('after flex login')
    
    # Make sure the signup link is gone and we're signed in
    check_element_hidden(:xpath, ".//div[@id='signup']")
    check_element_displayed(:xpath, ".//nav[@id='main_nav']//a[@class='sign_out']")

    # Make sure we are properly greeted
    greeting = ".//a[@class='greeting']"
    check_element_displayed(:xpath,greeting)
    check_element_value('Greetings, allaccess+test@redhat.com!',:xpath,greeting)

    # Make sure the dashboard link is there
    check_element_displayed(:xpath, ".//a[text()='Flex Console']")

    # Check the quickstart page
    find_element(:xpath, ".//a[text()='Quickstart']").click()
    screenshot('quickstart')
    check_title "OpenShift by Red Hat | Flex"
    check_element_displayed(:xpath, ".//section[@id='quickstart']")
  end
end
