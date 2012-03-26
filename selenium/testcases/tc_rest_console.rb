require 'openshift/selenium_test_case'

require 'openshift/rest/pages'
require 'openshift/rest/forms'
require 'openshift/rest/testcase'

class RestConsole < OpenShift::Rest::TestCase

  def setup
    super
    @app_counter = 0
  end

  def test_initial_redirect
    @login, pass = dummy_credentials
    signin(@login, pass)

    # on first open we should be redirected to the application_types page
    @rest_console.open
    assert_redirected_to(@rest_console.application_types_page.path)
  end

  def test_create_app_wizard
    @login, pass = dummy_credentials
    signin(@login, pass)

    app_types_page = @rest_console.application_types_page
    @rest_console.open
    app_type_buttons = app_types_page.find_create_buttons
    app_type = app_types_page.get_app_type(app_type_buttons[0])
    app_type_buttons[0].click

    assert_redirected_to "#{app_types_page.path}/#{app_type}"
    app_name = generate_app_name
    get_started_page = OpenShift::Rest::GetStartedPage.new(page, app_name)

    form = @rest_console.application_create_form
    form.set_value(:name, app_name)
    form.set_value(:namespace, @login)
    form.submit

    get_started_page.wait(90)

    app_link = get_started_page.find_app_link
    href = app_link.attribute('href')
    uri = URI.parse(href)

    assert uri.host.start_with? "#{app_name}-#{@login.downcase}"

    app_link.click

    assert_redirected_to href
  end

=begin

  def test_create_and_delete_apps

  end

  def test_ssh_key_invalid

  end

  def test_ssh_key_add

  end

  def test_add_invalid_app

  end

  def test_app_details

  end

=end
  private
    def generate_app_name(prefix="test")
      name = "#{prefix}#{@app_counter}"
      @app_counter+=1
      return name
    end
end
