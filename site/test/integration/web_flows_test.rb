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

  test 'validation on payment page' do
    skip unless Aria.available?

    with_logged_in_console_user
    
    begin
      billing_info = Aria::BillingInfo.test
      contact_info = Aria::ContactInfo.from_billing_info(billing_info)
      Aria::UserContext.new(@user).create_account({:billing_info => billing_info, :contact_info => contact_info})
    rescue Aria::AccountExists
    end

    visit edit_account_payment_method_path

    cc_no   = find('#aria_payment_method_cc_no')
    cc_mm   = find('#aria_payment_method_cc_exp_mm')
    cc_yyyy = find('#aria_payment_method_cc_exp_yyyy')
    cc_cvc  = find('#aria_payment_method_cvv')
    submit  = find("input[type=submit]")

    cc_no_selector = '#aria_payment_method_cc_no'
    cc_no_error_selector = '.error-client .help-inline[for=aria_payment_method_cc_no]'

    # Prevent actual submission
    page.execute_script('$("form").submit(function(){ return false; })')

    # Initial load
    assert has_css?(cc_no_selector), "Missing credit card number input"
    assert has_no_css?(cc_no_error_selector), "Should not have errors on initial load"

    # Required error on first click
    cc_no.set("")
    submit.click
    assert has_css?(cc_no_error_selector), "Should show a required error when submitting with empty credit card number"

    # Valid VISA format should pass
    cc_no.set("4111111111111111")
    submit.click
    assert has_no_css?(cc_no_error_selector), "Should allow valid VISA format"

    # Invalid VISA format should fail
    cc_no.set("4111111111111112")
    submit.click
    assert has_css?(cc_no_error_selector), "Should disallow invalid VISA format"

    # Valid Mastercard format should pass
    cc_no.set("5555555555554444")
    submit.click
    assert has_no_css?(cc_no_error_selector), "Should allow valid Mastercard format"

    # Disallow valid Amex format (disallowed type)
    cc_no.set("378282246310005")
    submit.click
    assert has_css?(cc_no_error_selector), "Should disallow unaccepted card type"

    # Set valid data
    cc_no.set("4111111111111111")
    cc_mm.set("1")
    cc_yyyy.set(Date.today.year + 1)
    cc_cvc.set("123")
    submit.click
    assert has_no_css?('.error-client'), "Errors were still shown after submitting valid data"
    assert has_css?('.icon-loading'), "Form submission did not trigger"
  end

  test 'vat number dynamic display' do
    with_logged_in_console_user

    visit edit_account_plan_upgrade_path(:silver)

    # On load, only US stuff is showing
    assert has_css?('h5.tax_nonvat')
    assert has_css?('p.tax_nonvat')
    assert has_no_css?('h5.tax_vat')
    assert has_no_css?('p.tax_vat')
    assert has_no_css?('.tax_vat input')

    # Simulate changing the value to Ireland
    page.execute_script("$('select[autocomplete=country]').val('IE').trigger('change')")

    # After changing to Ireland, VAT stuff is showing
    assert has_css?('h5.tax_vat')
    assert has_css?('p.tax_vat')
    assert has_css?('.tax_vat input')
    assert has_no_css?('h5.tax_nonvat')
    assert has_no_css?('p.tax_nonvat')

    find('.tax_vat input').set('IE')

    # Submit empty form using DOM method to bypass Javascript validation
    page.execute_script("$('form')[0].submit()")

    # Reloading the form on an EU country keeps VAT stuff showing, with an error on the VAT input
    assert has_css?('h5.tax_vat')
    assert has_css?('p.tax_vat')
    assert has_css?('.tax_vat.error input')
    assert has_no_css?('h5.tax_nonvat')
    assert has_no_css?('p.tax_nonvat')
  end

  test 'help page displays' do
    with_logged_in_console_user

    visit console_help_path
    assert has_css? 'h2', :text => /Create/
  end

  test 'jquery form validation triggers on submit' do
    visit login_path

    # Selectors
    username       = "#web_user_rhlogin"
    password       = "#web_user_password"
    username_error = "#web_user_rhlogin_input.error-client #web_user_rhlogin.error"
    password_error = "#web_user_password_input.error-client #web_user_password.error"

    # Fields
    assert has_css?(username), "Missing username field"
    assert has_css?(password), "Missing password field"
    submit = find("input[type=submit]")

    # Initial setup
    assert has_no_css?(username_error), "Username field should not have errors on page load"
    assert has_no_css?(password_error), "Password field should not have errors on page load"

    # Initial invalidation
    submit.click
    assert has_css?(username_error), "Empty username field should have errors after submitting"
    assert has_css?(password_error), "Empty password field should have errors after submitting"

    # Avoid revalidating
    page.execute_script("$('#web_user_rhlogin').val('a')")
    assert has_css?(username_error), "validate should not trigger on value change"
    page.execute_script("$('#web_user_rhlogin').trigger('keypress').trigger('keyup')")
    assert has_css?(username_error), "validate should not trigger on keyup"
    page.execute_script("$('#web_user_rhlogin').focus()")
    assert has_css?(username_error), "validate should not trigger on focus"
    page.execute_script("$('#web_user_rhlogin').blur()")
    assert has_css?(username_error), "validate should not trigger on blur"
    page.execute_script("$('#web_user_rhlogin').click()")
    assert has_css?(username_error), "validate should not trigger on click"

    # Revalidate
    submit.click
    assert has_no_css?(username_error), "revalidate should trigger on submit"
    assert has_css?(password_error), "revalidate should not clear error messages for invalid fields"
  end

end
