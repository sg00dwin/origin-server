$local_selenium = ENV['LOCAL_SELENIUM'] == '1'

require "test/unit"
require "openshift/base"
require "uri"
require "pathname"
require "selenium/client"
require "selenium/webdriver"
require "openshift/sauce_helper" unless $local_selenium

require 'openshift/rest/pages'
require 'openshift/rest/forms'
require 'openshift/rest/navbars'

module OpenShift
  class SeleniumTestCase < Test::Unit::TestCase
    include ::OpenShift::TestBase
    include ::OpenShift::SauceHelper unless $local_selenium
    include ::OpenShift::CSSHelpers
    include ::OpenShift::Assertions
    
    attr_reader :driver
    
    alias_method :page, :driver
    alias_method :selenium, :driver

    def self.local?
      $local_selenium || Sauce::Config.new().local?
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

      # Make this global so we can compare relative URIs even
      # if the app is not served from the root path
      $browser_url = browser_url

      if OpenShift::SeleniumTestCase.local?
        @driver = Selenium::WebDriver.for :firefox
        @driver.manage.timeouts.implicit_wait = 3
        @driver.navigate.to browser_url
      else
        cfg = Sauce::Config.new()
        opts = cfg.opts

        case opts[:browser] || ''
          when "iexplore"
            caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
          when "chrome"
            caps = Selenium::WebDriver::Remote::Capabilities.chrome
          when "opera"
            caps = Selenium::WebDriver::Remote::Capabilities.opera
          else
            caps = Selenium::WebDriver::Remote::Capabilities.firefox
        end

        platform = opts[:os] || ''
        case platform.downcase
          when "windows 2008"
            caps.platform = :VISTA
          when "linux"
            caps.platform = :LINUX
          else
            caps.platform = :XP
        end

        caps.version = opts[:browser_version] if opts[:browser_version]

        caps[:name] = get_name
        caps[:build] = ENV['JENKINS_BUILD'] || 'unofficial'

        caps[:"selenium-version"] = "2.7.0" if caps[:"selenium-version"].nil?
        if ENV["SAUCE_SELENIUM_VERSION"]
          caps[:"selenium-version"] = ENV["SAUCE_SELENIUM_VERSION"]
        end

        @driver = Selenium::WebDriver.for(
          :remote,
          :url => "http://#{opts[:username]}:#{opts[:access_key]}@#{opts[:host]}:#{opts[:port]}/wd/hub",
          :desired_capabilities => caps)
      end

      @page    = page

      @navbar  = OpenShift::Rest::MainNav.new(page,'main_nav')
      @home    = OpenShift::Rest::Home.new(page, "/")
      @login_page = OpenShift::Rest::Login.new(page,"/login")
      @logout = Proc.new { @page.get "#{browser_url}/logout"; wait_for_page "/" }

      @rest_console = OpenShift::Rest::Console.new(page, "/console")
      @rest_account = OpenShift::Rest::Account.new(page, "/account")
      @signup = OpenShift::Rest::Signup.new(page, "/account/new")
    end

    def run(*args, &blk)
      # suppress Test::Unit::TestCase#default_test placeholder test
      unless get_name =~ /^default_test/
        super(*args, &blk)
      end
    end

    def teardown
      if @driver
        unless passed?
          start_time = Time.now # comment out in Ruby 1.9.3
          image = "output/#{start_time.to_i.to_s[-4..-1]}_#{name}.png"
          html = "output/#{start_time.to_i.to_s[-4..-1]}_#{name}.html"
          begin
            Dir.mkdir 'output' rescue

            @driver.save_screenshot(image)

            File.open(html, 'w') do |f|
              f.write(@driver.page_source)
            end

            puts ":<logged to #{Pathname.new(image).realpath}>"
          rescue Exception => e
            print "<unable to output logs for #{name}"
            puts e.inspect
            puts ">"
          end
          sleep (ENV['SAUCE_SLEEP_ON_FAILURE'] || 0).to_i
        end

        # always make sure we clear the session
        signout

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
