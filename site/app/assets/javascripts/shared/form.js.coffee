$ = jQuery

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
      # Commented out for now; the new layout isn't currently compatible.
      #"aria_billing_info[first_name]":
      #  required: true
      #"aria_billing_info[last_name]":
      #  required: true
      "aria_billing_info[address1]":
        required: true
      #"aria_billing_info[city]":
      #  required: true
      #"aria_billing_info[state]":
      #  required: true
      "aria_billing_info[country]":
        required: true
      #"aria_billing_info[zip]":
      #  required: true

  # /app/account/plans/<plan>/upgrade/edit
  $('form#new_streamline_full_user').validate
    rules:
      # Commented out for now; the new layout isn't currently compatible.
      #"streamline_full_user[streamline_full_user][first_name]":
      #  required: true
      #"streamline_full_user[streamline_full_user][last_name]":
      #  required: true
      #"streamline_full_user[aria_billing_info][first_name]":
      #  required: true
      #"streamline_full_user[aria_billing_info][last_name]":
      #  required: true
      "streamline_full_user[aria_billing_info][address1]":
        required: true
      #"streamline_full_user[aria_billing_info][city]":
      #  required: true
      #"streamline_full_user[aria_billing_info][state]":
      #  required: true
      "streamline_full_user[aria_billing_info][country]":
        required: true
      #"streamline_full_user[aria_billing_info][zip]":
      #  required: true

