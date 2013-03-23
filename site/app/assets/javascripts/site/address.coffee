$ = jQuery

$ ->
  $.fn.addressForm = ->
    billing_selector_for = (name) ->
      billing_el('select',name)

    billing_input_for = (name) ->
      billing_el('input',name)

    billing_el = (type,name) ->
      $("#{type}[name$='[aria_billing_info][#{name}]']")

    billing_label_for = (el) ->
      el.closest('.control-group').find('.control-label')

    # Store our selections for easier use
    country_select   = billing_selector_for('country')
    region_select    = billing_selector_for('region')
    currency_select  = billing_selector_for('currency_cd')

    # Get the city/region/zip label
    region_label = billing_label_for(region_select)
    # Split the label into a list
    label_ul     = $('<ul/>')
    label_items  = region_label.text().split(', ')
    $.each(label_items, (i,val) ->
      $('<li/>')
        .text(val)
        .addClass(val.toLowerCase())
        .appendTo(label_ul)
    )
    region_label.html(label_ul)

    # Remove our empty placeholder
    region_select.find('option:empty').detach()
    # Store the region optgroups, this gets destroyed when we detach on change
    groups = region_select.html()

    country_select.on 'change', (ev) ->
      args = arguments[1] || {}

      # Find the selected country
      selected = $(this).find("option:selected")
      name = selected.text()
      code = selected.val()

      # Get options for the country
      currency    = selected.attr('data-currency')
      subdivision = selected.attr('data-subdivision') || "State"
      postal_code = selected.attr('data-postal_code') || "Postcode"

      # Replace the groups with our stored versions
      region_select.html(groups)
      # Remove any unwanted groups
      region_select.find("optgroup[label!='#{name}']").detach()
      # Promote the options so we don't see the optgroup
      region_select.html(region_select.find('option'))
      # Add a "default" value to the region select
      placeholder = $("<option value disabled>#{subdivision}</option>")
      unless args.first_run
        placeholder.attr('selected','selected')
      region_select.prepend(placeholder)

      # Change the state and postal code in the label
      region_label = billing_label_for(region_select)
      region_label.find('ul li.state').html(subdivision)
      region_label.find('ul li.zip').html(postal_code)
      billing_input_for('zip').attr('placeholder',postal_code)

      # Change the currency to the default for the country
      currency_select.val(currency) unless args.first_run

    # Update the form based on the current value
    country_select.trigger 'change', {first_run: true}
