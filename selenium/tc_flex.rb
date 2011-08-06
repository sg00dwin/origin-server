#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Flex < Test::Unit::TestCase
  include ::OpenShift::TestBase
  # Test Flex page contents
  def test_check_flex_contents
    $logger.info "start to check flex contents"
    goto_home
    find_element(:xpath,".//ul[@id='products']/li[2]/a").click()
    check_title "OpenShift by Red Hat | Flex"
    begin
      assert_equal "Need to auto-scale new and existing apps in the Cloud?", find_element(:xpath,".//div[@id='banner']/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Provision, deploy, monitor and auto-scale JBoss, Java EE6 and PHP apps", find_element(:xpath,".//div[@id='banner']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='product_videos']/h2").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "OpenShift Flex Product Tour", find_element(:xpath,".//div[@id='product_videos']/div/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video walks you through the high level functionality of OpenShift Flex, covering provisioning, deploying, monitoring and scaling applications in the cloud.", find_element(:xpath,".//div[@id='product_videos']/div/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "What are people saying about OpenShift?", find_element(:xpath,".//div[@id='product_videos']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video shows you what developers, ISVs, customers and partners are saying about Red Hat's exciting new OpenShift PaaS.", find_element(:xpath,".//div[@id='product_videos']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Deploying a Mongo Driven Application on OpenShift Flex", find_element(:xpath,".//div[@id='product_videos']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video walks a user through deploying an application on OpenShift Flex that uses MongoDB as its database backend. Complete with performance and log management demo!", find_element(:xpath,".//div[@id='product_videos']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Deploying a Seam Application on OpenShift Flex", find_element(:xpath,"//div[@id='product_videos']/div[4]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This video walks a user through deploying a Seam application on OpenShift Flex. Complete with a performance and log management demo!",find_element(:xpath,"//div[@id='product_videos']/div[4]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Subscribe to Announcements to get product release notifications.", find_element(:xpath,".//div[@id='product_community']/div/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Currently OpenShift Flex doesn't support Python / Django based applications, but there is a workaround. The solution is to use Jython - which generates Java bytecode from Python code. With project Django on Jython you will be able to generate a WAR file from your Django project and you can easily deploy it as a Tomcat application in OpenShift Flex.", find_element(:xpath,".//div[@id='product_community']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "NoSQL in the Cloud? No Problem - Deploying MongoDB on OpenShift Flex" , find_element(:xpath,".//div[@id='product_community']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "MongoDB is an open source document-oriented database designed with scalability and developer agility in mind. Instead of storing your data in tables and rows as you would with a relational database, with MongoDB you store (JSON-like) documents with dynamic schemas. The goal of MongoDB is to bridge the gap between key-value stores (which are fast and scalable) and relational databases (which have rich functionality). 10gen develops MongoDB, and offers production support, training, and consulting for the open source database", find_element(:xpath,".//div[@id='product_community']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Red Hat recently announced OpenShift, a PaaS from which you can use the available MongoDB cartridge to easily deploy and manage applications with a MongoDB backend.", find_element(:xpath,".//div[@id='product_community']/div[3]/p[3]").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "Getting Started with JBoss", find_element(:xpath,".//div[@id='product_community']/div[4]/h3").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert_equal "This comprehensive guide walks you through deploying, monitoring, managing, and auto-scaling a JBoss application on OpenShift Flex.", find_element(:xpath,".//div[@id='product_community']/div[4]/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
  end

  # Check Flex links
  def test_check_flex_links
    $logger.info "start to check flex links"
    goto_home
    find_element(:xpath,".//ul[@id='products']/li[2]/a").click()
    check_title "OpenShift by Red Hat | Flex"
    begin
      assert find_element(:xpath,".//div[@id='banner']/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Build')]").click()
    begin
      assert_equal "OpenShift Flex's wizard driven interface makes it easy to provision resources and build integrated application stacks.", find_element(:xpath,".//div[@id='step_1']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='step_1']/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Deploy')]").click()
    begin
      assert_equal "OpenShift Flex makes it easy to deploy your application, make modifications to code and components, version your changes and redeploy.",find_element(:xpath,".//div[@id='step_2']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='step_2']/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//a[contains(text(),'Monitor & Scale')]").click()
    begin
      assert_equal "Without the use of agents or scripts, OpenShift Flex gives you end-to-end monitoring straight-out-of-box with configurable auto-scaling that lets you decide when and how to scale your application.", find_element(:xpath,".//div[@id='step_3']/p").text
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='step_3']/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      find_element(:xpath,".//div[@id='resources']/ul/li/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='resources']/ul/li[2]/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='resources']/ul/li[3]/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    begin
      assert find_element(:xpath,".//div[@id='resources']/ul/li[4]/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
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
    sleep 2
    check_title "News and Announcements | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    check_title "Django Application in OpenShift Flex - Workaround | Red Hat Openshift Forum"
    @driver.navigate.back
    find_element(:xpath,".//div[@id='product_community']/div[3]/a").click()
    @driver.navigate.back
    begin
      assert find_element(:xpath,".//div[@id='product_community']/div[4]/a").displayed?
    rescue Test::Unit::AssertionFailedError
      @verification_errors << $!
    end
    find_element(:xpath,".//div[@id='product_videos']/a").click()
    check_title "Videos | Red Hat Openshift Forum"
    @driver.navigate.back
  end

end
