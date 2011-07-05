#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Flex < Test::Unit::TestCase

  def setup
    @verification_errors = []
    @headless = Headless.new
    @headless.start
    @driver=Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 5
    @url="http://localhost"
  end

  def teardown
    @driver.quit
    @headless.destroy
    assert_equal [], @verification_errors
  end
  # Test Flex page contents
  def test_check_flex_contents
    puts "start to check flex contents"
    @driver.navigate.to @url+"/app/"
    sleep 2
    assert !20.times{ break if ("OpenShift by Red Hat" == @driver.title rescue false); sleep 1 }
    @driver.find_element(:xpath,".//ul[@id='products']/li[2]/a").click()
    sleep 2
    assert !20.times{ break if ("OpenShift by Red Hat | Flex" == @driver.title rescue false); sleep 1 }
    begin
        assert_equal "Need to auto-scale new and existing apps in the Cloud?", @driver.find_element(:xpath,".//div[@id='banner']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Provision, deploy, monitor and auto-scale JBoss, Java EE6 and PHP apps", @driver.find_element(:xpath,".//div[@id='banner']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//div[@id='product_videos']/h2").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "OpenShift Flex Product Tour", @driver.find_element(:xpath,".//div[@id='product_videos']/div/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video walks you through the high level functionality of OpenShift Flex, covering provisioning, deploying, monitoring and scaling applications in the cloud.", @driver.find_element(:xpath,".//div[@id='product_videos']/div/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "What are people saying about OpenShift?", @driver.find_element(:xpath,".//div[@id='product_videos']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video shows you what developers, ISVs, customers and partners are saying about Red Hat's exciting new OpenShift PaaS.", @driver.find_element(:xpath,".//div[@id='product_videos']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Deploying a Mongo Driven Application on OpenShift Flex", @driver.find_element(:xpath,".//div[@id='product_videos']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end        
    begin
        assert_equal "This video walks a user through deploying an application on OpenShift Flex that uses MongoDB as its database backend. Complete with performance and log management demo!", @driver.find_element(:xpath,".//div[@id='product_videos']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Deploying a Seam Application on OpenShift Flex", @driver.find_element(:xpath,"//div[@id='product_videos']/div[4]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video walks a user through deploying a Seam application on OpenShift Flex. Complete with a performance and log management demo!",@driver.find_element(:xpath,"//div[@id='product_videos']/div[4]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Subscribe to Announcements to get product release notifications.", @driver.find_element(:xpath,".//div[@id='product_community']/div/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Currently OpenShift Flex doesn't support Python / Django based applications, but there is a workaround. The solution is to use Jython - which generates Java bytecode from Python code. With project Django on Jython you will be able to generate a WAR file from your Django project and you can easily deploy it as a Tomcat application in OpenShift Flex.", @driver.find_element(:xpath,".//div[@id='product_community']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "NoSQL in the Cloud? No Problem - Deploying MongoDB on OpenShift Flex" , @driver.find_element(:xpath,".//div[@id='product_community']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "MongoDB is an open source document-oriented database designed with scalability and developer agility in mind. Instead of storing your data in tables and rows as you would with a relational database, with MongoDB you store (JSON-like) documents with dynamic schemas. The goal of MongoDB is to bridge the gap between key-value stores (which are fast and scalable) and relational databases (which have rich functionality). 10gen develops MongoDB, and offers production support, training, and consulting for the open source database", @driver.find_element(:xpath,".//div[@id='product_community']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Red Hat recently announced OpenShift, a PaaS from which you can use the available MongoDB cartridge to easily deploy and manage applications with a MongoDB backend.", @driver.find_element(:xpath,".//div[@id='product_community']/div[3]/p[3]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Getting Started with JBoss", @driver.find_element(:xpath,".//div[@id='product_community']/div[4]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This comprehensive guide walks you through deploying, monitoring, managing, and auto-scaling a JBoss application on OpenShift Flex.", @driver.find_element(:xpath,".//div[@id='product_community']/div[4]/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

# Check Flex links
  def test_check_flex_links
    puts "start to check flex links"
    @driver.navigate.to @url+"/app/"
    sleep 2  
    assert !10.times{ break if ("OpenShift by Red Hat" == @driver.title rescue false); sleep 1 }
    @driver.find_element(:xpath,".//ul[@id='products']/li[2]/a").click()
    sleep 2
    assert !10.times{ break if ("OpenShift by Red Hat | Flex" == @driver.title rescue false); sleep 1 }
    begin
        assert @driver.find_element(:xpath,".//div[@id='banner']/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Build')]").click()
    sleep 1
    begin
        assert_equal "OpenShift Flex's wizard driven interface makes it easy to provision resources and build integrated application stacks.", @driver.find_element(:xpath,".//div[@id='step_1']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
    assert @driver.find_element(:xpath,".//div[@id='step_1']/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end 
    @driver.find_element(:xpath,".//a[contains(text(),'Deploy')]").click()
    sleep 1
    begin
        assert_equal "OpenShift Flex makes it easy to deploy your application, make modifications to code and components, version your changes and redeploy.",@driver.find_element(:xpath,".//div[@id='step_2']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
    assert @driver.find_element(:xpath,".//div[@id='step_2']/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end 
    @driver.find_element(:xpath,".//a[contains(text(),'Monitor & Scale')]").click()
    begin
        assert_equal "Without the use of agents or scripts, OpenShift Flex gives you end-to-end monitoring straight-out-of-box with configurable auto-scaling that lets you decide when and how to scale your application.", @driver.find_element(:xpath,".//div[@id='step_3']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
    assert @driver.find_element(:xpath,".//div[@id='step_3']/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end 
    sleep 1
    begin
    @driver.find_element(:xpath,".//div[@id='resources']/ul/li/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 3
    begin
        assert @driver.find_element(:xpath,".//div[@id='resources']/ul/li[2]/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//div[@id='resources']/ul/li[3]/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//div[@id='resources']/ul/li[4]/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='resources']/a").click()
    sleep 3
    assert !10.times{ break if ("Documents | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back

    @driver.find_element(:xpath, ".//div[@id='doc_link']/a").click()
    sleep 3
    assert !10.times{ break if ("Knowledge Base | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath, ".//div[@id='doc_link']/a[2]/p").click()
    sleep 2
    assert !10.times{ break if ("Documents | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
    sleep 2
    assert !10.times{ break if ("OpenShift by Red Hat | Flex" == @driver.title rescue false); sleep 1 }
    @driver.find_element(:xpath, ".//a[contains(text(),'Subscribe >')]").click()
    sleep 2
    assert !10.times{ break if ("News and Announcements | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
    @driver.find_element(:xpath,".//a[contains(text(),'Announcements')]").click()
    sleep 2
    assert !10.times{ break if ("News and Announcements | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    sleep 2
    assert !10.times{ break if ("Django Application in OpenShift Flex - Workaround | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
    @driver.find_element(:xpath,".//div[@id='product_community']/div[3]/a").click()
    @driver.navigate.back
    begin
        assert @driver.find_element(:xpath,".//div[@id='product_community']/div[4]/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='product_videos']/a").click()
    sleep 2
    assert !10.times{ break if ("Videos | Red Hat Openshift Forum" == @driver.title rescue false); sleep 1 }
    @driver.navigate.back
  end


end
