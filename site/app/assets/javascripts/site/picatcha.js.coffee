$ = jQuery

$ ->
  # We need this function to detect when the refresh button is dynamically created
  $.fn.waitUntilExists = (handler, shouldRunHandlerOnce, isChild) ->
    found = "found"
    $this = $(@selector)
    $elements = $this.not(->
      $(this).data found
    ).each(handler).data(found, true)
    unless isChild
      (window.waitUntilExists_Intervals = window.waitUntilExists_Intervals or {})[@selector] = window.setInterval(->
        $this.waitUntilExists handler, shouldRunHandlerOnce, true
      , 500)
    else window.clearInterval window.waitUntilExists_Intervals[@selector]  if shouldRunHandlerOnce and $elements.length
    $this

  # This will make the refresh link look like a button
  $('#picatcha a.picatchaRefreshButton').waitUntilExists (->
    $(this).addClass('btn btn-mini')
  ), true

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
