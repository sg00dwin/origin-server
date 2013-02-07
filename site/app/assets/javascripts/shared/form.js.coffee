$ = jQuery

@transport_form_data = (data_attr_name, form_field_selector) ->
  $("a[data-#{data_attr_name}]").click ->
    actual = $(form_field_selector)
    if actual and actual.val()
      sep = (if (@href.indexOf("?") isnt -1) then "&" else "?")
      @href = @href + sep + encodeURIComponent($(this).data(data_attr_name)) + "=" + encodeURIComponent(actual.val())
    true;

$ ->
  # /app/account/new
  # /app/account
  $('form#new_user_form').validate
    rules:
      # Require email for new users
      "web_user[email_address]":
        required:   true
        email:      true
      # Require old password for password change
      "web_user[old_password]" :
        required:   true
      "web_user[password]":
        required:   true
        minlength:  6
      "web_user[password_confirmation]":
        required:   true
        equalTo:    "#web_user_password"

  # /app/login
  $('form#login_form').validate
    rules:
      "web_user[rhlogin]":
        required: true
      "web_user[password]":
        required: true

  # /payment
  $('form#payment_method').validate
    rules:
      "cc_no":
        required: true
        creditcard: true
      "cvv":
        required: true

  $('form#edit_aria_billing_info').validate
    rules:
      "aria_billing_info[first_name]":
        required: true
      "aria_billing_info[last_name]":
        required: true
      "aria_billing_info[address1]":
        required: true
      "aria_billing_info[city]":
        required: true
      "aria_billing_info[state]":
        required: true
      "aria_billing_info[country]":
        required: true
      "aria_billing_info[zip]":
        required: true

  # /app/account/plans/<plan>/upgrade/edit
  $('form#upgrade_account_new_streamline_full_user').validate
    rules:
      "streamline_full_user[streamline_full_user][first_name]":
        required:   true
      "streamline_full_user[streamline_full_user][last_name]":
        required:   true
      "streamline_full_user[streamline_full_user][title]":
        required:   true
      "streamline_full_user[streamline_full_user][company]":
        required:   true
      "streamline_full_user[streamline_full_user][phone_number]":
        required:   true
        maxlength:  10
      "streamline_full_user[streamline_full_user][password]":
        required:   true
        minlength:  6
      "streamline_full_user[streamline_full_user][password_confirmation]":
        required:   true
        equalTo:    "#upgrade_account_upgrade_account_streamline_full_user_streamline_full_user_password"
      "streamline_full_user[aria_billing_info][first_name]":
        required:   true
      "streamline_full_user[aria_billing_info][last_name]":
        required:   true
      "streamline_full_user[aria_billing_info][address1]":
        required:   true
      "streamline_full_user[aria_billing_info][city]":
        required:   true
      "streamline_full_user[aria_billing_info][state]":
        required:   true
      "streamline_full_user[aria_billing_info][zip]":
        required:   true
      "streamline_full_user[aria_billing_info][country]":
        required:   true
