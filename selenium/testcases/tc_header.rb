#!/usr/bin/env ruby
class Header < Sauce::TestCase
  include ::OpenShift::TestBase
  include ::OpenShift::CSSHelpers
  include ::OpenShift::Assertions

  def setup
    super
    @home.open
  end

  def test_header_links
    @home.click(@home.items[:logo])
    assert_redirected_to '/app'
  end

  def test_navbar_links
    links = {
      :platform_overview => '/app/platform',
      :express => '/app/express',
      :flex => '/app/flex',
      :community => 'https://www.redhat.com/openshift/'
    }

    links.each do |name,url|
      @home.open
      @navbar.click(name)
      assert_redirected_to("#{url}")
    end
  end
end
