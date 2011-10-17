#!/usr/bin/env ruby
require "test/unit"
require "rubygems"
require 'selenium-webdriver'
require 'headless'

class Footer < Test::Unit::TestCase
  include ::OpenShift::TestBase

  # Only test internal RH resources
  def test_footer
    goto_home

    { 'Announcements' => 'News and Announcements | Red Hat OpenShift Community',
      'Blog' => 'Openshift Blogs | Red Hat OpenShift Community',
      'Forum' => 'Forums | Red Hat OpenShift Community',
      'Partner Program' => 'OpenShift by Red Hat | Meet Our Partners',
      'Legal' => 'OpenShift by Red Hat | Terms and Conditions',
      'Privacy Policy' => 'OpenShift by Red Hat | OpenShift Privacy Statement',
    }.each do |text,title|
      find_element(:xpath,".//a[text()='#{text}']").click()
      screenshot(text)
      check_title(title)
      @driver.navigate.back
    end
  end
end
