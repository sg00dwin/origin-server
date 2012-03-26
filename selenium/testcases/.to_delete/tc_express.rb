#!/usr/bin/env ruby
class Express < OpenShift::SeleniumTestCase

  def setup
    super
    @express.open
  end

  def test_public_express_links
    # These links just change the position on the page, so no page load
    check_links({
      :whats_express => '/app/express#about',
      :videos => '/app/express#videos',
    })

    # External links
    check_links({
      :documentation => 'http://docs.redhat.com/docs/en-US/OpenShift_Express/2.0/html/User_Guide/index.html',
      :forum => 'https://www.redhat.com/openshift/community/forums/express',
    })

    # Make sure we get the signup link
    @express.open
    @express.click(:signup)
    assert @signup.is_open?
    @signup.click(:close)
  end

  def test_authorized_express_links
    signin 

    check_links({
      :quickstart => '/app/express#quickstart',
    })

    check_links({
      :console => '/app/control_panel'
    })
  end

  def check_links(hash)
    hash.each do |name,url|
      @express.open
      @express.click(name)
      assert_redirected_to("#{url}")
    end
  end
end
