#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Express < Test::Unit::TestCase
  include ::OpenShift::TestBase
  # Check express page contents
  def test_check_express_contents
    $logger.info "start to check express page contents"
    goto_home
    find_element(:xpath,"//a[contains(@href, '/app/express')]").click()
    begin
      assert_equal "Get Ruby, PHP and Python apps in the cloud with just a few lines of code.", find_element(:xpath,".//div[@id='banner']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Install')]").click()
    begin
      assert_equal "Download and install the OpenShift Express client tools so you can deploy and manage your application in the cloud.", find_element(:xpath,".//div[@id='step_1']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//a[contains(text(),'Watch the video >>>')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Create')]").click()
    begin
      assert_equal "Create a subdomain for your application and clone the Git master repository from the cloud.", find_element(:xpath,".//div[@id='step_2']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Deploy')]").click()
    begin
      assert_equal "Add your application code to the Git repository and push to the cloud. Congratulations, your application is live!", find_element(:xpath,".//div[@id='step_3']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "AVAILABLE PLATFORMS", find_element(:xpath,".//div[@id='platforms']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='product_videos']/h2").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video walks you through the high level functionality of OpenShift Express, from installing the client tools, creating a subdomain to deploying your app onto the cloud.", find_element(:xpath,".//div[@id='product_videos']/div/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Mobile App Deployment to Express w/ Appcelerator", find_element(:xpath,".//div[@id='product_videos']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video shows you just how easy it is to develop and deploy a mobile app onto OpenShift Express with Appcelerator's Mobile Cloud Platform", find_element(:xpath,".//div[@id='product_videos']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Deploying to OpenShift PaaS with the eXo Cloud IDE", find_element(:xpath,".//div[@id='product_videos']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video demonstrates how easy it is to use the eXo cloud IDE to develop and deploy applications on OpenShift.", find_element(:xpath,".//div[@id='product_videos']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//img[@alt='OpenShift Express Product Tour']").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//img[@alt='OpenShift Appcelerator Demo']").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//img[@alt='Deploying to OpenShift PaaS with the eXo Cloud IDE']").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//a[contains(text(),'More Videos >')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Community Highlights", find_element(:xpath,".//div[@id='product_community']/h2").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Announcements", find_element(:xpath,".//div[@id='product_community']/div/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Subscribe to Announcements to get product release notifications.", find_element(:xpath,".//div[@id='product_community']/div/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "You ask for it, you get it with Openshift Express!", find_element(:xpath,".//div[@id='product_community']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Since our release at Summit in early May, we've been busy collecting your feedback, fixing bugs and dropping in new features and enhancements. First off, thank you for all the input and exchanges in the forums and IRC! To make sure that you know you're being heard, we wanted to recap the issues and bugs that have been fixed plus highlight some new features and coming attractions.", find_element(:xpath,".//div[@id='product_community']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "How do I delete from Persistant Storage?", find_element(:xpath,".//div[@id='product_community']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This thread discusses persistent storage on OpenShift Express.", find_element(:xpath,"//div[@id='product_community']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end
  # Check express page links

  def test_check_express_links
    $logger.info "start to check express page links"
    goto_home
    find_element(:xpath,".//a[contains(@href, '/app/express')]").click()
    find_element(:xpath,".//img[@alt='OpenShift by Red Hat Cloud']").click()
    @driver.navigate.back
    find_element(:xpath,".//div[@id='banner']/a").click()
    begin
      assert_equal "TRY EXPRESS", find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.navigate.back
    begin
      assert find_element(:xpath,".//a[contains(text(),'OpenShift Express User Guide')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Eval_Guide.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//div[@id='doc_link']/a/p").click()
    check_title "Knowledge Base | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='doc_link']/a[2]/p").click()
    check_title "Documents | Red Hat Openshift Forum"
    @driver.navigate.back
    begin
      assert find_element(:xpath,".//a[contains(text(),'Watch the video >>>')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'More information >')]").click()
    check_title "Frequently Asked Questions | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//a[contains(text(),'Announcements')]").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    begin
      assert_equal "OpenShift > Forums > News and Announcements", find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.navigate.back
    check_title "OpenShift by Red Hat | Express"
    find_element(:xpath,".//div[@id='product_community']/div/a").click()
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    check_title "OpenShift Express -- Getting Started with Drupal | Red Hat Openshift Forum"
    begin
      assert_equal "OpenShift > Videos > OpenShift Express -- Getting Started with Drupal", find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_videos']/a").click()
    check_title "Videos | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,"//div[@id='product_community']/div[3]/a").click()
    begin
      assert_equal "OpenShift > Forums > Express > How do I delete from Persistant Storage?", find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  # check express getting started page
  def test_getting_started_express
    $logger.info "start to check express getting started page"
    login("xtian+test@redhat.com", "123456")
    begin
      assert find_element(:xpath,".//div[@id='button']/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//div[@id='button']/a").click()
    sleep 2
    check_title "OpenShift by Red Hat | Express"
    begin
      assert find_element(:xpath,".//a[contains(@href, '/app/repo/openshift.repo')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
=begin
    find_element(:xpath, ".//ol[@id='toc']/li[2]/a").click()
    begin
      assert_equal "Create a domain name", find_element(:xpath,".//li[@id='create_domain_name']//h4[1]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.navigate.back
    find_element(:xpath, ".//ol[@id='toc']/li[3]/a").click()
    begin
      assert_equal "Create your first application", find_element(:xpath,".//li[@id='create_application']/h4").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    @driver.navigate.back
=end

    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    begin
      assert find_element(:xpath,".//a[contains(@href, '/app/login')]").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end
end
