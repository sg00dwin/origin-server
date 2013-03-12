$ = jQuery

@transport_form_data = (data_attr_name, form_field_selector) ->
  $("a[data-#{data_attr_name}]").click ->
    actual = $(form_field_selector)
    if actual and actual.val()
      sep = (if (@href.indexOf("?") isnt -1) then "&" else "?")
      @href = @href + sep + encodeURIComponent($(this).data(data_attr_name)) + "=" + encodeURIComponent(actual.val())
    true;

# Helper function to check an elements classes against an array
@has_class = (el, classes) ->
  retval = false
  $.each(classes, (i,klass) ->
    if el.hasClass(klass)
      retval = true
  )
  return retval

# Helper function to place errors in the nearest help-inline block
# This is useful for grouped elements
@help_inline_placement = (el,error) ->
  err_block = el.closest('.control-group').find('p.help-inline')
  unless err_block.length == 0
    err_block.replaceWith error
  else
    error.insertAfter(el)

$ ->
  # Get the value from one of the form's meta tags
  $.fn.form_meta_value = (name) ->
    $(this).closest('form').find("meta[name=#{name}]").attr('content')

  ####
  # Custom validation methods
  ####
  $.validator.addMethod "cc_no", ((val,el) ->
    $.payment.validateCardNumber(val)
  ), "Please enter a valid credit card number"

  $.validator.addMethod "accepted_card", ((val, el) ->
    accepted_cards = $(el).form_meta_value('accepted_card_types').split(':')
    has_class($(el),accepted_cards)
  ), "Please use an accepted card type"

  $.validator.addMethod "cvv", ((val,el) ->
    # Get the card type if we have a number
    cc_no = $('input[name="cc_no"]').val()
    cc_type = $.payment.cardType(cc_no)

    $.payment.validateCardCVC(val, cc_type)
  ), "Please enter a valid security code"

  # This method is safe to include from jquery.payment
  # It only compares the dates and doesn't do any CC parsing
  $.validator.addMethod 'cc_exp', ((val,el) ->
    exp_m = $('select[name="cc_exp_mm"]').val()
    exp_y = $('select[name="cc_exp_yyyy"]').val()
    $.payment.validateCardExpiry(exp_m, exp_y)
  ), "Please enter a valid expiration date"

  $.validator.addMethod 'intl_phone', ((val,el) ->
    val.match(/^[0-9)(x+. -]*[0-9]$/)
  ), "Please enter a valid phone number"

  # /app/account/new
  # /app/account
  $('form#new_user_form').validate
    # This is needed so we can hide the Picatcha error placeholder
    ignore: ""
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
      # Validate that the user has submitted captcha input
      "picatcha_images":
        picatcha:   true
      "recaptcha_response_field":
        required:   true

  # /app/login
  $('form#login_form').validate
    rules:
      "web_user[rhlogin]":
        required: true
      "web_user[password]":
        required: true

  # Only include certain extended validation rules if the view set window.extended_cc_validation
  # The cc_exp rules are safe because they're just doing Date comparision, nothing to do with CC
  $('form#payment_method').validate
    groups:
      expiration: "cc_exp_mm cc_exp_yyyy"
    errorPlacement: (error, el) ->
      help_inline_placement(el,error)
    rules:
      "cc_no":
        required: true
        cc_no: window.extended_cc_validation
        accepted_card: window.extended_cc_validation
      "cvv":
        required: true
        cvv: window.extended_cc_validation
      "cc_exp_mm":
        required: true
        cc_exp: true
      "cc_exp_yyyy":
        required: true
        cc_exp: true

  ###
  #  The following validations apply to the plan upgrade forms
  ###

  # Helper function to add simple validations to the form
  $.fn.add_validations = (groups, namespace) ->
    form = $(this)
    for group,names of groups
      for name in names
        # Get the proper input field
        input = form.find("[name$='[#{namespace}][#{name}]']")
        # Add it to a group if specified
        if group != 'nil'
          form.data().validator.groups[input.attr('name')] = group
        # Add the required rules
        input.rules "add",
          required: true
    form

  # The following groups of fields are required with no extra options
  # The hash key is used to place them in groups for validator
  contact_fields = {
    'contact_name': ['first_name','last_name'],
    'contact_company': ['title','company']
  }

  billing_fields = {
    'billing_name': ['first_name', 'last_name'],
    'billing_city': ['city', 'region', 'zip']
    nil:            ['address1','country']
  }

  ###
  # Create the validations for the forms
  # - Call validate with base options and any specific fields
  # - Call add_validations to add fields that are grouped and/or just have a 'required' rule
  ###

  # /account/plans/:id/upgrade/edit
  streamline_full_user_form = $('form#upgrade_account_new_streamline_full_user')
  if streamline_full_user_form.length > 0
    $(streamline_full_user_form)
      .validate
        errorPlacement: (error, el) ->
          help_inline_placement(el,error)
        rules:
          "streamline_full_user[streamline_full_user][phone_number]":
            required:     true
            rangelength:  [8,30]
            intl_phone:   true
          "streamline_full_user[streamline_full_user][password]":
            required:   true
            minlength:  6
          "streamline_full_user[streamline_full_user][password_confirmation]":
            required:   true
            equalTo:    "#upgrade_account_upgrade_account_streamline_full_user_streamline_full_user_password"

    streamline_full_user_form
      .add_validations(contact_fields, 'streamline_full_user')
      .add_validations(billing_fields, 'aria_billing_info')

  # /account/plans/:id/upgrade/billing_info/edit
  edit_aria_billing_info_form = $('form#edit_aria_billing_info')
  if edit_aria_billing_info_form.length > 0
    $(edit_aria_billing_info).validate
      errorPlacement: (error, el) ->
        help_inline_placement(el,error)

    edit_aria_billing_info_form
      .add_validations(billing_fields, 'aria_billing_info')
