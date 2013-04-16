require File.expand_path('../../test_helper', __FILE__)

class WebFlowsTest < ActionDispatch::IntegrationTest
  web_integration

  test 'login to console' do
    with_unique_user
    visit_console_login

    assert has_content? /Management Console/i

    find('header .nav', :visible => true).click_link 'My Account'

    assert find('.nav > li.active').has_content? 'My Account'
    assert has_content? 'Free Plan'
  end

  test 'logout from console' do
    with_unique_user
    visit_console_login

    assert link = find('#utility-nav a', :text => 'Sign Out', :visible => false)

    assert find('#utility-nav a.dropdown-toggle').click
    assert link.visible?
    assert find('#utility-nav').click_link 'Sign Out'

    visit console_path
    assert_equal login_path, URI(page.current_url).path
  end

  test 'tag dropdown on application types page' do
    with_logged_in_console_user
    
    visit application_types_path

    assert has_css?('.tile h3', :text => /Ruby 1\.(\d)/)
    assert find('.tile h3', :text => /Drupal/)
    assert find('.nav > li.active').has_content? 'Create Application'
    assert page.has_content? /Create an application/i

    assert find('a.dropdown-toggle', :text => /Browse by tag/).click
    assert find('#tag-filter a', :text => /PHP/).click

    assert find('h3', :text => /Tagged with php/)
    assert has_css?('.tile h3', :text => /Drupal/)    
  end

  test 'help page displays' do
    with_logged_in_console_user

    visit console_help_path
    assert has_css? 'h2', :text => /Create/
  end
end
