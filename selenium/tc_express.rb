#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Express < Test::Unit::TestCase
  include ::OpenShift::TestBase
  
  # Check express page links
  def test_check_express_links
    $logger.info "Testing express page links"
    goto_home
    find_element(:xpath,".//a[contains(@href, '/app/express')]").click()
    find_element(:xpath,".//img[@alt='OpenShift by Red Hat Cloud']").click()
    @driver.navigate.back
    check_element_displayed(:xpath, ".//a[contains(text(),'OpenShift Express User Guide')]")
    check_element_displayed(:xpath, ".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Eval_Guide.pdf')]")
    check_element_displayed(:xpath, ".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf')]")
    check_element_displayed(:xpath, ".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf')]")
    find_element(:xpath,".//div[@id='doc_link']/a/p").click()
    check_title "Knowledge Base | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='doc_link']/a[2]/p").click()
    check_title "Documents | Red Hat Openshift Forum"
    @driver.navigate.back
    check_element_displayed(:xpath, ".//a[contains(text(),'Watch the video >>>')]")
    find_element(:xpath,".//a[contains(text(),'More information >')]").click()
    check_title "Frequently Asked Questions | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Announcements')]").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    check_title "OpenShift by Red Hat | Express"
    find_element(:xpath,".//div[@id='product_community']/div/a").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    check_title "OpenShift Express -- Getting Started with Drupal | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_videos']/a").click()
    check_title "Videos | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,"//div[@id='product_community']/div[3]/a").click()
  end

  # check express getting started page
  def test_getting_started_express
    $logger.info "Testing express getting started page"
    login("xtian+test@redhat.com", "123456")
    check_element_displayed(:xpath, ".//div[@id='button']/a")
    find_element(:xpath,".//div[@id='button']/a").click()
    check_title "OpenShift by Red Hat | Express"
    check_element_displayed(:xpath, ".//a[contains(@href, '/app/repo/openshift.repo')]")
=begin
    find_element(:xpath, ".//ol[@id='toc']/li[2]/a").click()
    check_element_value("Create a domain name", :xpath, ".//li[@id='create_domain_name']//h4[1]")
    @driver.navigate.back
    find_element(:xpath, ".//ol[@id='toc']/li[3]/a").click()
    check_element_value("Create your first application", :xpath, ".//li[@id='create_application']/h4")
    @driver.navigate.back
=end

    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    check_element_displayed(:xpath, ".//a[contains(@href, '/app/login')]")
  end
end
