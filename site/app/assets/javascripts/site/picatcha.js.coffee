$ = jQuery

$ ->
  # Helper to see if we've selected any Picatcha images
  picatcha_selected = ->
    $('#picatcha_table img.selected').length > 0

  $.validator.addMethod "picatcha", ((value, el, params) ->
    picatcha_selected()
  ), ""#"Please complete the following captcha"

  # TODO: For some reason, the checkbox was not being checked when the image was clicked
  #       This was causing the Picatcha logic to not deselect images
  #       This worked on their demo page, so I believe it has something to do with validator
  $('#captcha_inputs').on 'click', '#picatcha_widget img', (ev) ->
    img  = $(ev.target)
    ckbx = img.closest('.picatcha_td').find('input[type=checkbox]')
    ckbx.attr('checked', img.hasClass('selected') )
    true # Allow this to bubble up

  $('#captcha_inputs').on 'click', '#picatcha_widget:has(p.help-inline[generated=true]) img', (ev) ->
    selected = picatcha_selected()
    $('#picatcha_widget p.help-inline').toggle(!selected)
    $('#picatcha_widget').toggleClass('error', !selected)
