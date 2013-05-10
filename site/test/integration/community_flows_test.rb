require File.expand_path('../../test_helper', __FILE__)

class CommunityFlowsTest < ActionDispatch::IntegrationTest
  web_integration

  test 'community homepage and signup page render' do
    visit community_url

    assert has_content? /Develop and scale apps in the cloud/i

    assert has_css?(".news a"), "No blog posts on the homepage"

    assert has_css?("#buzz-retweets > .tweet"), "No retweets on the homepage"
    assert has_css?("#buzz-tweets > .tweet"), "No tweets on the homepage"

    click_link('Sign Up')

    assert find('h1', :text => 'Create an account')
  end

  test 'login and logout of community' do
    visit community_base_url('user')

    assert find('h2', :text => 'Enter your OpenShift login')
    within "#user-login" do
      fill_in 'name', :with => ENV['COMMUNITY_USER'] || 'test'
      fill_in 'pass', :with => ENV['COMMUNITY_PASSWORD'] || 'test'
    end

    click_button('Sign In')

    assert has_css?('body.page-user')
    assert has_link?('Edit my profile')
    assert has_link?('Sign Out of the Community')

    click_link('Sign Out of the Community')

    assert has_content? /Develop and scale apps in the cloud/i
  end

  test 'megamenu dropdowns' do
    visit community_url

    #check that the menu is there but hidden
    link = all('ul.nav li.dropdown').last
    dropdown = link.find('.dropdown-menu', :visible => false)
    assert !dropdown.visible?

    link.hover

    #check that the menu can still be found but only if it is visible, and a link can be clicked
    assert dropdown.visible?
    menu_link = dropdown.all('a').first
    href = menu_link['href']
    menu_link.click
    assert_equal href, URI(page.current_url).path
  end
end
