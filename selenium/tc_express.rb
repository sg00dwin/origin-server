#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Express < Test::Unit::TestCase

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
# Check express page contents  
  def test_check_express_contents
    puts "start to check express page contents"
    @driver.navigate.to @url+"/app/"
    sleep 2
    begin
    assert_equal "OpenShift by Red Hat",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:xpath,"//a[contains(@href, '/app/express')]").click()     
    sleep 2
    begin
        assert_equal "Get Ruby, PHP and Python apps in the cloud with just a few lines of code.", @driver.find_element(:xpath,".//div[@id='banner']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Install')]").click()
    begin
        assert_equal "Download and install the OpenShift Express client tools so you can deploy and manage your application in the cloud.", @driver.find_element(:xpath,".//div[@id='step_1']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(text(),'Watch the video >>>')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Create')]").click()
    begin
        assert_equal "Create a subdomain for your application and clone the Git master repository from the cloud.", @driver.find_element(:xpath,".//div[@id='step_2']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'Deploy')]").click()
    begin
        assert_equal "Add your application code to the Git repository and push to the cloud. Congratulations, your application is live!", @driver.find_element(:xpath,".//div[@id='step_3']/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "AVAILABLE PLATFORMS", @driver.find_element(:xpath,".//div[@id='platforms']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//div[@id='product_videos']/h2").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video walks you through the high level functionality of OpenShift Express, from installing the client tools, creating a subdomain to deploying your app onto the cloud.", @driver.find_element(:xpath,".//div[@id='product_videos']/div/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Mobile App Deployment to Express w/ Appcelerator", @driver.find_element(:xpath,".//div[@id='product_videos']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video shows you just how easy it is to develop and deploy a mobile app onto OpenShift Express with Appcelerator's Mobile Cloud Platform", @driver.find_element(:xpath,".//div[@id='product_videos']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Deploying to OpenShift PaaS with the eXo Cloud IDE", @driver.find_element(:xpath,".//div[@id='product_videos']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This video demonstrates how easy it is to use the eXo cloud IDE to develop and deploy applications on OpenShift.", @driver.find_element(:xpath,".//div[@id='product_videos']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//img[@alt='OpenShift Express Product Tour']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//img[@alt='OpenShift Appcelerator Demo']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//img[@alt='Deploying to OpenShift PaaS with the eXo Cloud IDE']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(text(),'More Videos >')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Community Highlights", @driver.find_element(:xpath,".//div[@id='product_community']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Announcements", @driver.find_element(:xpath,".//div[@id='product_community']/div/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Subscribe to Announcements to get product release notifications.", @driver.find_element(:xpath,".//div[@id='product_community']/div/p").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "You ask for it, you get it with Openshift Express!", @driver.find_element(:xpath,".//div[@id='product_community']/div[2]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "Since our release at Summit in early May, we've been busy collecting your feedback, fixing bugs and dropping in new features and enhancements. First off, thank you for all the input and exchanges in the forums and IRC! To make sure that you know you're being heard, we wanted to recap the issues and bugs that have been fixed plus highlight some new features and coming attractions.", @driver.find_element(:xpath,".//div[@id='product_community']/div[2]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "How do I delete from Persistant Storage?", @driver.find_element(:xpath,".//div[@id='product_community']/div[3]/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert_equal "This thread discusses persistent storage on OpenShift Express.", @driver.find_element(:xpath,"//div[@id='product_community']/div[3]/p[2]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
# Check express page links

  def test_check_express_links
    puts "start to check express page links"
    @driver.navigate.to @url+"/app/"
    sleep 2
    begin
    assert_equal "OpenShift by Red Hat",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 1
    @driver.find_element(:xpath,".//a[contains(@href, '/app/express')]").click()     
    sleep 2
    @driver.find_element(:xpath,".//img[@alt='OpenShift by Red Hat Cloud']").click()
    sleep 2
    assert "OpenShift by Red Hat" == @driver.title 
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//div[@id='banner']/a").click()
    sleep 2
    begin
    assert_equal "TRY EXPRESS", @driver.find_element(:xpath,".//div[@id='title']/h2").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    begin
        assert @driver.find_element(:xpath,".//a[contains(text(),'OpenShift Express User Guide')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    sleep 2
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Eval_Guide.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='doc_link']/a/p").click()
    sleep 2
    begin
    assert_equal "Knowledge Base | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end   
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//div[@id='doc_link']/a[2]/p").click()
    sleep 2
    begin
    assert_equal "Documents | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end     
    @driver.navigate.back
    sleep 2
    begin 
        assert @driver.find_element(:xpath,".//a[contains(text(),'Watch the video >>>')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//a[contains(text(),'More information >')]").click()
    sleep 2
    begin
    assert_equal "Frequently Asked Questions | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end  
    @driver.navigate.back
    @driver.find_element(:xpath,".//a[contains(text(),'Announcements')]").click()
    sleep 2
    begin
    assert_equal "News and Announcements | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end     
    begin
    assert_equal "OpenShift > Forums > News and Announcements", @driver.find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end  
    @driver.navigate.back
    begin
    assert_equal "OpenShift by Red Hat | Express",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end     
    @driver.find_element(:xpath,".//div[@id='product_community']/div/a").click()
    sleep 2
    begin
    assert_equal "News and Announcements | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end  
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//div[@id='product_community']/div[2]/a").click()
    sleep 2
    begin
    assert_equal "OpenShift Express -- Getting Started with Drupal | Red Hat Openshift Forum",@driver.title
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
    assert_equal "OpenShift > Videos > OpenShift Express -- Getting Started with Drupal", @driver.find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 2
    @driver.find_element(:xpath,".//div[@id='product_videos']/a").click()
    sleep 2
    begin
    assert_equal "Videos | Red Hat Openshift Forum", @driver.title 
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    sleep 3
    @driver.find_element(:xpath,"//div[@id='product_community']/div[3]/a").click()
    sleep 2
    begin
        assert_equal "OpenShift > Forums > Express > How do I delete from Persistant Storage?", @driver.find_element(:xpath,".//div[@id='content']/div").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end

# check express getting started page
  def test_getting_started_express
    puts "start to check express getting started page"
    @driver.navigate.to @url+"/app/"
    sleep 2
    begin
        assert @driver.find_element(:xpath,"//div[@id='login']/a")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath, ".//div[@id='login']/a").click()
    @driver.find_element(:xpath,".//div[@id='login-form']/form/input[3]").send_keys("xtian+test@redhat.com")
    @driver.find_element(:xpath,".//div[@id='login-form']/form/input[4]").send_keys("123456")
    @driver.find_element(:xpath, "//div[@id='login-form']/form/input[7]").click()
    sleep 2
    begin
        assert @driver.find_element(:xpath,".//div[@id='button']/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@id='flex_console_link']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.find_element(:xpath,".//div[@id='button']/a").click()
    sleep 2
    assert !10.times{ break if ("OpenShift by Red Hat | Get Started with Express" == @driver.title rescue false); sleep 1 }
    @driver.find_element(:xpath, ".//ol[@id='toc']/li/a").click()
    begin
        assert_equal "Install the client tools", @driver.find_element(:xpath,".//li[@id='install_client_tools']/h3").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//ol[@id='toc']/li[2]/a").click()
    begin
        assert_equal "Create a domain name", @driver.find_element(:xpath,".//li[@id='create_domain_name']//h4[1]").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//ol[@id='toc']/li[3]/a").click()
    begin
        assert_equal "Create your first application", @driver.find_element(:xpath,".//li[@id='create_application']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//ol[@id='toc']/li[4]/a").click()
    begin
        assert_equal "Make a change, publish", @driver.find_element(:xpath,".//li[@id='publish']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//ol[@id='toc']/li[5]/a").click()
    begin
        assert_equal "Next steps", @driver.find_element(:xpath,".//li[@id='next_steps']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//div[@id='install_toc']/ul/li/a").click()
    begin
        assert_equal "Red Hat Enterprise Linux or Fedora", @driver.find_element(:xpath,"//li[@id='rhel']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//div[@id='install_toc']/ul/li[2]/a").click()
    begin
        assert_equal "Other Linuxes", @driver.find_element(:xpath,".//li[@id='other_nix']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, "//div[@id='install_toc']/ul/li[3]/a").click()
    begin
        assert_equal "Mac", @driver.find_element(:xpath,"//li[@id='mac']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.navigate.back
    @driver.find_element(:xpath, ".//div[@id='install_toc']/ul/li[4]/a").click()
    begin
        assert_equal "Windows", @driver.find_element(:xpath,"//li[@id='win']/h4").text
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, '/app/repo/openshift.repo')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://www.youtube.com/watch?v=KLtbuvyJFFE']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://developer.apple.com/xcode']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://code.google.com/p/git-osx-installer/']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://www.cygwin.com']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://www.youtube.com/watch?v=p83Cx6s_q1U']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://www.youtube.com/watch?v=H9rMgKCoW3w']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/blogs/deploying-turbogears2-python-web-framework-using-express')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/blogs/deploying-a-pyramid-application-in-a-virtual-python-wsgi-environment-on-red-hat-openshift-expr')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//li[@id='next_steps']/ul/li/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//a[@href='http://docs.redhat.com/docs/en-US/OpenShift_Express/1.0/html/User_Guide/index.html']").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    begin
        assert @driver.find_element(:xpath,".//li[@id='next_steps']/ul/li[3]/a").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @driver.manage.delete_cookie("_rhc_session")
    @driver.manage.delete_cookie("rh_sso")
    @driver.navigate.refresh
    begin
        assert @driver.find_element(:xpath,".//a[contains(@href, '/app/login')]").displayed?
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end   
  end
end
