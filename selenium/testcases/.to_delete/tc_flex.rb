#!/usr/bin/env ruby
class Flex < OpenShift::SeleniumTestCase

  def setup
    super
    @flex.open
  end

  def test_public_flex_links
    # These links just change the position on the page, so no page load
    check_links({
      :whats_flex => '/app/flex#about',
      :videos => '/app/flex#videos',
    })

    # External links
    check_links({
      :documentation => 'http://docs.redhat.com/docs/en-US/OpenShift_Flex/1.0/html/User_Guide/index.html',
      :forum => 'https://www.redhat.com/openshift/community/forums/flex',
    })

    # Make sure we get the signup link
    @flex.open
    @flex.click(:signup)
    assert @signup.is_open?
    @signup.click(:close)
  end

  def test_authorized_flex_links
    signin

    check_links({
      :quickstart => '/app/flex#quickstart',
    })
  end

  def check_links(hash)
    hash.each do |name,url|
      @flex.open
      @flex.click(name)
      assert_redirected_to("#{url}")
    end
  end
end
