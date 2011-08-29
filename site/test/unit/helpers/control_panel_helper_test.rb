require 'test_helper'

class ControlPanelHelperTest < ActionView::TestCase

  def setup
    @userinfo = Object.new
    @userinfo.namespace = 'testns'
    @userinfo.rhc_domain = 'testdom'
    @userinfo.app_info = { 'testapp' => { 'uuid' => 'testuuid' }}
  end
  
  test 'app url is correct' do
    assert app_url_for @userinfo, 'testapp' == 'testapp-testns.testdom'
  end
  
  test 'git url is correct' do
    assert git_url_for @userinfo, 'testapp' == 'ssh://testuuid@testapp-testns.testdom/~/git/testapp.git/'
  end

end
