#!/usr/bin/env ruby

require 'rubygems'
require 'headless'
require 'selenium-webdriver'

# Create a headless display
headless = Headless.new
headless.start

driver = Selenium::WebDriver.for :firefox

puts "Navigating to main page"
driver.navigate.to 'http://localhost'

puts "Logging in"
driver.find_element(:link_text, 'LOGIN').click()
driver.find_element(:id, 'login_input').send_keys('test@redhat.com')
pwd = driver.find_element(:id, 'pwd_input')
pwd.send_keys('none')
pwd.submit()

puts "Saving a screenshot"
driver.save_screenshot('logged_in.png')

# Cleanup headless display
headless.destroy
