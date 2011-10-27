#!/usr/bin/env ruby
class Home < Sauce::TestCase
  include ::OpenShift::TestBase

  def setup
    super
    set_vars(page)
    @home.open
  end

  def test_homepage_title
    assert_match @home.fields[:title], @home.title
  end

  def test_signup_links
    @home.items[:signup_links].each do |link|
      @home.click(link)
      assert @signup.is_open?
      @signup.click(:close)
    end
  end
end
