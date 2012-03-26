#!/usr/bin/env ruby
class Home < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open
  end

  def test_homepage_title
    assert_match @home.fields[:title], @home.title
  end

=begin
  def test_signup_links
    @home.items[:signup_links].each do |link|
      @home.click(link)

      await("signup dialog open") { @signup.is_open? }

      @signup.click(:close)
    end
  end
=end
end
