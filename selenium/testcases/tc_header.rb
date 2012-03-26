#!/usr/bin/env ruby
class Header < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open
  end

  def test_header_links
    @home.click(@home.items[:logo])
    assert_redirected_to '/app'
  end

# FIXME: Navbar links no longer have ids.
=begin
  def test_navbar_links
    links = {
      :platform_overview => '/app/platform',
      :express => '/app/express',
      :flex => '/app/flex',
      :community => 'https://www.redhat.com/openshift/community/'
    }

    links.each do |name,url|
      @home.open
      @navbar.click(name)
      assert_redirected_to("#{url}")
    end
  end
=end
end
