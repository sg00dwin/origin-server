#!/usr/bin/env ruby
class Flex < Sauce::TestCase
  include ::OpenShift::TestBase
  include ::OpenShift::CSSHelpers
  include ::OpenShift::Assertions

  def setup
    super
    set_vars(page)
    @flex.open
  end

  def test_public_flex_links
    # These links just change the position on the page, so no page load
    check_links({
      :whats_flex => '/app/flex#about',
      :videos => '/app/flex#videos',
    },false)

    # External links
    check_links({
      :documentation => 'http://docs.redhat.com/docs/en-US/OpenShift_Flex/1.0/html/User_Guide/index.html',
      :forum => 'https://www.redhat.com/openshift/forums/flex',
    })

    # Make sure we get the signup link
    @flex.open
    @flex.click(:signup)
    assert @signup.is_open?
    @signup.click(:close)
  end

  def test_authorized_flex_links
    signin 
    @page.wait_for(:wait_for => :page)

    check_links({
      :quickstart => '/app/flex#quickstart',
    },false)

    check_links({
      #:console => '/app/dashboard'
    })
  end

  def check_links(hash,wait=true)
    hash.each do |name,url|
      @flex.open
      @flex.click(name)
      assert_redirected_to("#{url}",wait)
    end
  end
end
