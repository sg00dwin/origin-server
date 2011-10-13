#!/usr/bin/env ruby
class Home < Sauce::TestCase
  include ::OpenShift::TestBase

  def setup
    super
    page.open "/app"
  end

  def test_homepage_title
    assert_equal page.title, MAIN_TITLE, "Testing the main title"
  end

end
