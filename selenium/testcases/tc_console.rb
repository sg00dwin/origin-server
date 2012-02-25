require 'openshift/selenium_test_case'
require 'openshift/express/dialogs'
require 'openshift/express/navbars'
require 'openshift/express/pages'
require 'openshift/express/forms'

class ExpressConsole < OpenShift::SeleniumTestCase

  def setup
    super
  end

  def test_create_namespace_blank
    @login, pass = dummy_credentials
    signin(@login, pass)

    @express_console.open

    form = @express_console.domain_form

    form.expand
    await("form expanded") { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.submit

    assert form.in_error?(:namespace)
    assert_equal_no_case "This field is required.", form.error_message(:namespace)
  end

  def test_create_namespace_invalid
    @login, pass = dummy_credentials
    signin(@login, pass)

    @express_console.open

    form = @express_console.domain_form

    form.expand
    await("form expanded") { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, "non-alphanumeric!")

    form.submit

    assert form.in_error?(:namespace)
    assert_equal_no_case "Only letters and numbers are allowed", form.error_message(:namespace)
  end

  def test_create_namespace_valid
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)
  end

  def test_update_namespace
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)

    # leave and come back
    @express.open
    @express_console.open

    form = @express_console.domain_form
    assert form.collapsed?

    form.expand
    await("form expanded") { !form.collapsed? }

    new_namespace = @login + "a"

    form.set_value(:namespace, new_namespace)
    assert form.get_value(:namespace) != @login

    form.submit

    await("form collapsed", 30) { form.collapsed? }

    await("namespace updated on page") { new_namespace == form.get_collapsed_value(:namespace) }
  end

  def test_app_create_validation
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)

    jump_to "apps"

    form = @express_console.app_form

    assert !form.in_error?(:app_name)
    assert !form.in_error?(:cartridge)

    # try with no input

    form.submit
    wait_for_ajax

    assert form.in_error?(:app_name)
    assert form.in_error?(:cartridge)

    assert_equal_no_case "This field is required.", form.error_message(:app_name)
    assert_equal_no_case "This field is required.", form.error_message(:cartridge)

    # try to use non-alphanumeric app name

    form.set_value(:app_name, "Non-alphanumeric")

    assert form.in_error?(:app_name)
    assert_equal_no_case "Only letters and numbers are allowed", form.error_message(:app_name)

    # try to use app name that exceeds max length (32)

    app_name = "abcdefghijklmnopqrstuvwxyz0123456789"

    form.set_value(:app_name, app_name)

    assert !form.in_error?(:app_name)

    assert_equal app_name[0..31], form.get_value(:app_name)

  end

  def test_app_create
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)

    form = @express_console.app_form

    jump_to "apps"

    n = 5
    for i in 1.upto(n) do
      type = get_option_value(form.fields[:cartridge], i)
      create_app(@login, pass, "app#{i}", type)
    end

    # TODO assert cannot create more
  end

  def test_ssh_keys
    @login, pass = dummy_credentials

    signin(@login, pass)
    @express_console.open

    # no domain, should show placeholder
    assert driver.find_element(:css => '.ssh-placeholder').displayed?

    create_namespace(@login, pass, @login, false)

    return #FIXME ssh key creation has changed dramatically, fix with new console

    # create a default SSH key
    driver.find_element(:css => '.ssh-widget .popup-trigger .button.create').click

    form = @express_console.ssh_key_form('default')
    assert_equal "SSH PUBLIC KEY (DEFAULT)*", form.label(:key_string)   

    key = dummy_ssh_key
    form.set_value(:key_string, key)
    form.submit

    await('preview SSH key') { driver.find_element(:css => '#label_ssh_key_default.primary_key') }
    assert_equal 'default', driver.find_element(:css => '#label_ssh_key_default').text
    preview = driver.find_element(:css => '#preview_ssh_key_default code').text.sub(/\.\.\.$/, '')
    assert_equal 0, key.index(preview)
    
    # has edit link, but no delete link
    assert exists?('#preview_ssh_key_default .edit-key-link')
    assert !exists?('#preview_ssh_key_default .delete-key-link')

    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt').length
    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt.primary_key').length

    # create a secondary SSH key
    driver.find_element(:css => '.ssh-widget .popup-trigger .button.create').click

    form = @express_console.ssh_key_form('new')

    key = dummy_ssh_key
    form.set_value(:name, 'key1')
    form.set_value(:key_string, key)
    form.submit

    await('preview SSH key') { driver.find_element(:css => '#label_ssh_key_key1') }
    assert_equal 'key1', driver.find_element(:css => '#label_ssh_key_key1').text
    preview = driver.find_element(:css => '#preview_ssh_key_key1 code').text.sub(/\.\.\.$/, '')
    assert_equal 0, key.index(preview)
    
    # has edit link and delete link
    assert exists?('#preview_ssh_key_key1 .edit-key-link')
    assert exists?('#preview_ssh_key_key1 .delete-key-link')

    assert_equal 2, driver.find_elements(:css => '.ssh-widget dl dt').length
    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt.primary_key').length

    # edit the primary key
    driver.find_element(:css => '#preview_ssh_key_default .edit-key-link').click

    form = @express_console.ssh_key_form('default')

    key = dummy_ssh_key
    form.set_value(:key_string, key)
    form.submit

    sleep 1 # wait for display to re-draw

    await('preview SSH key') { driver.find_element(:css => '#label_ssh_key_default') }
    assert_equal 'default', driver.find_element(:css => '#label_ssh_key_default').text
    preview = driver.find_element(:css => '#preview_ssh_key_default code').text.sub(/\.\.\.$/, '')
    assert_equal 0, key.index(preview)

    assert_equal 2, driver.find_elements(:css => '.ssh-widget dl dt').length
    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt.primary_key').length

    # edit the extra key
    driver.find_element(:css => '#preview_ssh_key_key1 .edit-key-link').click

    form = @express_console.ssh_key_form('key1')

    key = dummy_ssh_key
    form.set_value(:key_string, key)
    form.submit

    sleep 1 # wait for display to re-draw

    await('preview SSH key') { driver.find_element(:css => '#label_ssh_key_key1') }
    assert_equal 'key1', driver.find_element(:css => '#label_ssh_key_key1').text
    preview = driver.find_element(:css => '#preview_ssh_key_key1 code').text.sub(/\.\.\.$/, '')
    assert_equal 0, key.index(preview)

    assert_equal 2, driver.find_elements(:css => '.ssh-widget dl dt').length
    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt.primary_key').length

    # delete the extra key
    driver.find_element(:css => '#preview_ssh_key_key1 .delete-key-link a').click
    assert driver.find_element(:css => "#key1_delete_form").displayed?
    driver.find_element(:css => '.popup-content input.delete_button').click

    await("hide delete popup") { !driver.find_element(:css => '#cp-dialog').displayed? }

    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt').length
    assert_equal 1, driver.find_elements(:css => '.ssh-widget dl dt.primary_key').length
  end

  private

  def get_option_value(select_id, preferred_index)
    select = driver.find_elements(:xpath => "//select[@id='#{select_id}']")[0]
    options = select.find_elements(:css => "option")

    i = preferred_index % options.length
    options[i].attribute "value"
  end

  def jump_to(id)
    exec_js "jQuery('html,body').scrollTop(jQuery('##{id}').offset().top - 50)"
  end

  # helper method for creating an app
  # pre: user is signed in already
  # post: user is on express console page
  def create_app(login, password, app_name, type)
    form = @express_console.app_form

    assert !form.in_error?(:app_name)
    assert !form.in_error?(:cartridge)

    form.set_value(:app_name, app_name)
    form.set_value(:cartridge, type)

    jump_to "apps"

    form.submit

    wait_for_ajax 30

    # presence of deletion form indicates successful creation
    await("#{type} app created") { exists? "form##{app_name}_delete_form" }
  end

  # helper method for creating a namespace
  # post: user is on express console page
  def create_namespace(login, password, namespace, log_in=true)
    if log_in
      signin(login, password)
    end

    @express_console.open

    form = @express_console.domain_form

    form.expand
    await("form expanded") { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, namespace)

    form.submit

    wait_for_ajax 30

    await("namespace created") { namespace == form.get_collapsed_value(:namespace) }
  end

  def dummy_credentials
    return ["test#{data[:uid]}", data[:password]]
  end

  def dummy_ssh_key(type='ssh-rsa')
    "#{type} AAAA#{Time.now.to_f.to_s.sub('.', '/')}B3NzaC1kc3MAAACBAOmtY5dhWtrsoFFlc6hjhTcu7ZEV/V4iCixcpbMedboUfiWz2Fd6x2zLrsx432Dh7IDPz2/KwW5M+h7Ns0E7rLQvJbeB7NAXjKrgTPQiuKmhx+czDQmy5KdINtddHRR0TARpd5aSE6MHTIgav8+9bvM1h5s3S1g7khempam+0Wq/AAAAFQDrV0Jcs+YjxH5OMTAKJOzmEiyAswAAAIBsykXvxFzro6KtGn7gfeyfJSTvE7UtswYi2TqU8Hopbor0fAKKw2oKo3jJB4/fM0sm7s61i0YgLkv++tEDF1xUJnTVElZkRVIdhtNo1CnlOMkLoUnIaCubhbyDaV5oPMMHDx6QrCLz1rUFLwjGoZeuzoqXaY43aTG9dZiFZdB/SQAAAIEArHL0J93k6yz6/8/gfXKMqa1xk+i0F+9ARuw0VzHw3tn1EeVlvAXukS1ZnHriK+08kX3kI4ZQejdKyTAFu4UWLJacjg+jDj5qXeQLxrHE8tXrfLboszQriV5Pg9e2qjwSso4irXkptbomie1IcdlCA0lZC6auIAoLCKa3cILojKE="
  end
end
