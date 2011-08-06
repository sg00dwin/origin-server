#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Flex < Test::Unit::TestCase
  include ::OpenShift::TestBase

  # Check Flex links
  def test_check_flex_links
    $logger.info "Testing flex links"
    goto_home
    find_element(:xpath,".//ul[@id='products']/li[2]/a").click()
    check_title "OpenShift by Red Hat | Flex"
    check_element_displayed(:xpath, ".//div[@id='banner']/a")
    find_element(:xpath,".//a[contains(text(),'Build')]").click()
    check_element_displayed(:xpath, ".//div[@id='step_1']/a")
    find_element(:xpath,".//a[contains(text(),'Deploy')]").click()
    check_element_displayed(:xpath, ".//div[@id='step_2']/a")
    find_element(:xpath,".//a[contains(text(),'Monitor & Scale')]").click()
    check_element_displayed(:xpath, ".//div[@id='step_3']/a")
    check_element_displayed(:xpath, ".//div[@id='resources']/ul/li/a")
    check_element_displayed(:xpath, ".//div[@id='resources']/ul/li[2]/a")
    check_element_displayed(:xpath, ".//div[@id='resources']/ul/li[3]/a")
    check_element_displayed(:xpath, ".//div[@id='resources']/ul/li[4]/a")
    find_element(:xpath,".//div[@id='resources']/a").click()
    check_title "Documents | Red Hat Openshift Forum"
    @driver.navigate.back

    find_element(:xpath, ".//div[@id='doc_link']/a").click()
    check_title "Knowledge Base | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath, ".//div[@id='doc_link']/a[2]/p").click()
    check_title "Documents | Red Hat Openshift Forum"
    @driver.navigate.back
    check_title "OpenShift by Red Hat | Flex"
    find_element(:xpath, ".//a[contains(text(),'Subscribe >')]").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Announcements')]").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    check_title "Django Application in OpenShift Flex - Workaround | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[3]/a").click()
    @driver.navigate.back
    check_element_displayed(:xpath, ".//div[@id='product_community']/div[4]/a")
    find_element(:xpath,".//div[@id='product_videos']/a").click()
    check_title "Videos | Red Hat Openshift Forum"
    @driver.navigate.back
  end

end
