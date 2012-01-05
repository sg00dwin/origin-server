require "rubygems"
require "test/unit"
require "openshift/base"
require "openshift/sauce_helper"

module OpenShift
  class SeleniumTestCase < Test::Unit::TestCase
    include ::OpenShift::TestBase
    include ::OpenShift::SauceHelper
    include ::OpenShift::CSSHelpers
    include ::OpenShift::Assertions
    
    attr_reader :driver
    
    alias_method :page, :driver
    alias_method :selenium, :driver

    def self.local?
      # ENV['LOCAL_SELENIUM']
      cfg = Sauce::Config.new()
      return cfg.local?
    end

    def setup
      super

      #hostname = get_my_hostname
      hostname = "localhost"

      if ENV['SAUCE_BROWSER_URL']
        browser_url = ENV['SAUCE_BROWSER_URL']
        uri = URI.parse(browser_url)
        hostname = uri.host
      end

      base_url = "https://#{hostname}"

      unless browser_url
        browser_url = "#{base_url}/app"
      end

      if OpenShift::SeleniumTestCase.local?
        @driver = Selenium::WebDriver.for :firefox
        @driver.navigate.to browser_url
      else
        cfg = Sauce::Config.new()

        driver_cfg = {}
        driver_cfg[:browser_url] = browser_url
        driver_cfg[:job_name] = get_name
        driver_cfg[:os] = cfg['os'] if cfg['os']
        driver_cfg[:browser] = cfg['browser'] if cfg['browser']
        driver_cfg[:browser_version] = cfg['browser-version'] if cfg['browser-version']
        driver_cfg[:build] = ENV['JENKINS_BUILD'] || 'unofficial'

        @driver = build_driver(driver_cfg)
      end

      @page    = page
      @home    = OpenShift::Express::Home.new(page, "#{base_url}/app")
      @express = OpenShift::Express::Express.new(page, "#{base_url}/app/express")
      @flex    = OpenShift::Express::Flex.new(page, "#{base_url}/app/flex")
      @express_console = OpenShift::Express::ExpressConsole.new(page, "#{base_url}/app/dashboard")

      @navbar  = OpenShift::Express::MainNav.new(page,'main_nav')
      @signin  = OpenShift::Express::Login.new(page,'signin')
      @reset   = OpenShift::Express::Reset.new(page,'reset_password')
      @signup  = OpenShift::Express::Signup.new(page,'signup')
    end

    def run(*args, &blk)
      # suppress Test::Unit::TestCase#default_test placeholder test
      unless get_name =~ /^default_test/
        super(*args, &blk)
      end
    end

    def teardown
      if @driver
        @driver.quit

        unless OpenShift::SeleniumTestCase.local?
          set_meta(session_id, {:passed => @test_passed})
        end
      end
      
      super
    end
    
    def get_name
      if self.respond_to? :name
        return self.name
      else
        return self.__name__
      end
    end
  end
end
