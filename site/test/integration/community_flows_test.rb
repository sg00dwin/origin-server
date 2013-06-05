require File.expand_path('../../test_helper', __FILE__)

class CommunityFlowsTest < ActionDispatch::IntegrationTest
  web_integration

  test 'community homepage and signup page render' do
    visit community_url

    assert has_content? /What others are saying/i

    assert has_css?("#buzz-retweets > .tweet"), "No retweets on the homepage"

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

    assert has_content? /What others are saying/i
  end

  test 'megamenu dropdowns' do
    visit community_url

    #check that the menu is there but hidden
    assert link = all('ul.nav li.dropdown').find{ |l| l.find('.dropdown-menu', :visible => false) }
    assert dropdown = link.find('.dropdown-menu', :visible => false)
    #assert !dropdown.visible?

    link.hover

    #check that the menu can still be found but only if it is visible, and a link can be clicked
    assert dropdown.visible?
    menu_link = dropdown.all('a').first
    href = menu_link['href']
    menu_link.click
    assert_equal href, URI(page.current_url).path
  end

  test 'Products navigation' do
    verify_tabs('Products', ['Online', 'Enterprise', 'Origin', 'Pricing'])
  end

  test 'Get Involved navigation' do
    verify_tabs('Get Involved',['Blog', 'Events', 'Vote on Features', 'Application Gallery'])
  end

  test 'Dev Center navigation' do
    verify_tabs('Dev Center', ['QuickStarts', 'Technologies', 'Documentation'])
  end

  test 'Products dropdown menu' do
    verify_dropdown('Products', ['Online', 'Enterprise', 'Origin', 'Pricing'])
  end

  test 'Get Involved dropdown menu' do
    verify_dropdown('Get Involved', ['Blog', 'Events', 'Vote on Features', 'Application Gallery'])
  end

  test 'Dev Center dropdown menu' do
    verify_dropdown('Dev Center', ['QuickStarts', 'Technologies', 'Documentation'])
  end

  test 'Support dropdown menu' do
    verify_dropdown('Support', ['FAQs', 'Forum', 'Knowledge Base'])
  end

  private

  def verify_tabs(link_text, nav_items)
    visit community_url

    click_link link_text

    nav = find('ul.nav-tabs')

    nav_items.each do |link|
      assert nav.has_link? link
    end
  end

  def verify_dropdown(link_text, menu_items)
    visit community_url
    dropdown = all('li.dropdown').find { |e| e.has_link? link_text }

    # Verify that the menu items are in place
    menu_items.each do |link|
      assert dropdown.has_link? link
    end

    # Verify that hovering over the menu makes it appear
    dropdown.hover
    assert dropdown.find('.dropdown-menu').visible?
  end
end
