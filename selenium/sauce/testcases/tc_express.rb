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

  # helper method for creating a namespace
  # post: user is on express console page
  def create_namespace(login, password, namespace)
    signin(login, password)
    
    @express_console.open

    form = @express_console.domain_form

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, namespace)

    form.submit

    await { form.collapsed? }

    await { namespace == form.get_collapsed_value(:namespace) }
  end
 
  def dummy_credentials
    return ["test#{data[:uid]}", data[:password]]
  end

  # helper method to wait for a (ruby) condition to become true
  # TODO: consider either moving this to TestBase or using a different technique
  def await(timeout_secs=5)
    if block_given?
      while true
        begin
          if yield
            return
          else
            raise StandardError, "block evaluated false", caller
          end
        rescue
          sleep 1
          timeout_secs -= 1
          if timeout_secs <= 0
            raise
          end
        end
      end
    end
  end

  def check_links(hash,wait=true)
    hash.each do |name,url|
      @express.open
      @express.click(name)
      assert_redirected_to("#{url}",wait)
    end
  end
end
