#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Express < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  # Check express page links
  def test_check_public_express_links
    $logger.info "Testing express page links"
    goto_home
    goto_express
    screenshot('after goto express')

    find_element(:xpath,".//a[@href='#about']").click()
    screenshot('About')
    check_title('OpenShift by Red Hat | Express')
    @driver.navigate.back


    { 'Videos' => 'OpenShift by Red Hat | Express',
      'Documentation' => 'User Guide',
      'Forum' => 'Express | Red Hat Openshift Forum'
    }.each do |text,title|
      find_element(:xpath,".//a[text()='#{text}']").click()
      screenshot(text)
      check_title(title)
      @driver.navigate.back
    end

    # Make sure sign in link pops up form
    link = find_element(:xpath, ".//a[text()='Sign up to try Express!']")
    # Make sure sign in dialog is hidden, shows up, and hides again
    signup = ".//div[@id='signup']"
    check_element_hidden(:xpath, signup)
    link.click()
    screenshot('signup dialog')
    check_element_displayed(:xpath, signup)
    find_element(:xpath,"#{signup}//a[@class='close_button']").click()
    check_element_hidden(:xpath, signup)
  end

  def test_check_logged_in_express_links
    goto_home
    goto_express
    login("allaccess+test@redhat.com", "123456")
    screenshot('after express login')

    # Make sure the signup link is gone and we're signed in
    check_element_hidden(:xpath, ".//div[@id='signup']")
    check_element_displayed(:xpath, ".//nav[@id='main_nav']//a[@class='sign_out']")

    # Make sure we are properly greeted
    greeting = ".//a[@class='greeting']"
    check_element_displayed(:xpath,greeting)
    check_element_value('Greetings, allaccess+test@redhat.com!',:xpath,greeting)

    # Make sure the dashboard link is there
    check_element_displayed(:xpath, ".//li/a[@href='/app/dashboard']")

    # Check the quickstart page
    find_element(:xpath, ".//a[text()='Quickstart']").click()
    screenshot('quickstart')
    check_title "OpenShift by Red Hat | Express"
    check_element_displayed(:xpath, ".//section[@id='quickstart']")
  end
end
