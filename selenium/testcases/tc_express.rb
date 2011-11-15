#!/usr/bin/env ruby
class Express < Sauce::TestCase
  include ::OpenShift::TestBase
  include ::OpenShift::CSSHelpers
  include ::OpenShift::Assertions

  def setup
    super
    @express.open
  end

  def test_public_express_links
    # These links just change the position on the page, so no page load
    check_links({
      :whats_express => '/app/express#about',
      :videos => '/app/express#videos',
    },false)

    # External links
    check_links({
      :documentation => 'https://docs.redhat.com/docs/en-US/OpenShift_Express/1.0/html/User_Guide/index.html',
      :forum => 'https://www.redhat.com/openshift/forums/express',
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
    },false)

    check_links({
      :console => '/app/dashboard'
    })
  end
  
  def test_create_namespace_blank
    @login, pass = dummy_credentials
    signin(@login, pass)
    
    @express_console.open

    form = @express_console.domain_form

    form.expand
    await { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.submit

    assert form.in_error?(:namespace)
    assert_equal "This field is required.", form.error_message(:namespace)
  end
  
  def test_create_namespace_invalid
    @login, pass = dummy_credentials
    signin(@login, pass)
    
    @express_console.open
    
    form = @express_console.domain_form

    form.expand
    await { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, "non-alphanumeric!")

    form.submit

    assert form.in_error?(:namespace)
    assert_equal "Only letters and numbers are allowed", form.error_message(:namespace)
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
    await { !form.collapsed? }

    new_namespace = @login + "a"

    form.set_value(:namespace, new_namespace) 
    assert form.get_value(:namespace) != @login

    form.submit

    await(30) { form.collapsed? }

    await { new_namespace == form.get_collapsed_value(:namespace) }
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

  def get_option_value(select_id, preferred_index)
    base = "//select[@id='#{select_id}']"
    ct = @page.get_xpath_count("#{base}/option").to_i
    i = preferred_index % ct
    return @page.get_attribute("#{base}/option[#{i+1}]/@value")
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

    form.submit

    await { form.processing? }

    await(30) { !form.processing? }

    # presence of deletion form indicates successful creation
    await { @page.element? "//form[@id='#{app_name}_delete_form']" }
  end

  # helper method for creating a namespace
  # post: user is on express console page
  def create_namespace(login, password, namespace)
    signin(login, password)
    
    @express_console.open

    form = @express_console.domain_form

    form.expand
    await { !form.collapsed? }

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, namespace)

    form.submit

    await { form.collapsed? }

    await { namespace == form.get_collapsed_value(:namespace) }
  end
 
  def dummy_credentials
    return ["test#{data[:uid]}", data[:password]]
  end

  def check_links(hash,wait=true)
    hash.each do |name,url|
      @express.open
      @express.click(name)
      assert_redirected_to("#{url}",wait)
    end
  end
end
