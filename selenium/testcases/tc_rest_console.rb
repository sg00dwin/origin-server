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
    @login, pass, namespace = dummy_credentials
    signin(@login, pass)

    app_types_page = @rest_console.application_types_page
    @rest_console.open
    app_type_buttons = app_types_page.find_create_buttons
    app_type = app_types_page.get_app_type(app_type_buttons[1])
    app_type_buttons[1].click

    assert_redirected_to "#{app_types_page.path}/#{app_type}"
    app_name = generate_app_name
    get_started_page = OpenShift::Rest::GetStartedPage.new(page, app_name)

    form = @rest_console.application_create_form
    form.set_value(:name, app_name)
    form.set_value(:namespace, namespace)
    form.submit

    get_started_page.wait(90)

    app_link = get_started_page.find_app_link
    href = app_link.attribute('href')
    uri = URI.parse(href)

    assert uri.host.start_with? "#{app_name}-#{namespace.downcase}"
  end

  def test_create_and_delete_apps
    @login, pass, namespace = dummy_credentials
    signin(@login, pass)

    app_type_buttons = find_app_type_buttons
    app_type_buttons.each_with_index do |item, index|
      delete_app 0 if index > 2

      # create all app types available
      if index == 0
        # skip jboss
      elsif index == 1
        # first one we need to create a namespace
        create_app index, namespace.downcase
      else
        create_app index
      end
    end
  end

=begin
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

    def find_app_type_buttons
      @rest_console.application_types_page.find_create_buttons
    end

    def delete_app(index=0)
      apps_page = @rest_console.applications_page
      app_details_page = @rest_console.application_details_page

      apps_page.open
      app_buttons = apps_page.find_app_buttons
      app_name = apps_page.get_app_name(app_buttons[index])
      app_buttons[index].click

      assert_redirected_to "#{app_details_page.path}/#{app_name}"

      del_button = app_details_page.find_delete_button
      del_button.click
      app_details_page.application_delete_form.submit
    end

    def create_app(type_index=1, namespace=nil)
      app_types_page = @rest_console.application_types_page
      app_types_page.open
      app_type_buttons = find_app_type_buttons
      app_type = app_types_page.get_app_type(app_type_buttons[type_index])
      app_type_buttons[type_index].click

      assert_redirected_to "#{app_types_page.path}/#{app_type}"
      app_name = generate_app_name
      get_started_page = OpenShift::Rest::GetStartedPage.new(page, app_name)

      form = @rest_console.application_create_form
      form.set_value(:name, app_name)
      form.set_value(:namespace, namespace) unless namespace.nil?
      form.submit

      get_started_page.wait(180)

      app_link = get_started_page.find_app_link
      href = app_link.attribute('href')
      uri = URI.parse(href)

      assert uri.host.start_with? "#{app_name}-#{namespace}"
    end
end
