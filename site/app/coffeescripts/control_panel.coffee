$ = jQuery

shorten = (str, len) ->
  if str.length > len
    str.slice(0, len) + '...'
  else
    str

$ ->
  # Set up widgets
  
  # Create dialog
  cpDialog = $ """
    <div id="cp-dialog"></div>
  """
  ($ 'body').append cpDialog
  cpDialog.osDialog()

  # Set up pop-ups
  ($ '.edit-widget .popup').osPopup dialog: cpDialog, modal: true, keepindom: true
  ($ '#apps .popup').osPopup dialog: cpDialog, modal: true, keepindom: true
  ($ '.inline-docs-widget').osPopup dialog: cpDialog
  
  # Bind elements to data
  ($ '.domain-widget').osData event: 'domain_form_return', onEvent: (event) ->
    ($ '.error', cpDialog).remove()
    if event.osEventStatus == 'success'
      # Success
      ($ '.current', this).text event.osEventData.namespace
      ($ '.popup', this).osPopup 'unpop'
      # update hidden form value in ssh form
      ($ '#ssh_form_express_domain_namespace').val(event.osEventData.namespace)
      if event.osEventData.action == 'create'
        ($ '#express_domain_dom_action').val('update')
        ($ '.ssh-form', '#ssh_container').show()
        ($ '.ssh-placeholder', '#ssh_container').remove()
        # show app form too
        ($ '.app-form', '#app_form_container').show()
        ($ '.app-placeholder', '#app_form_container').hide()
      else
        # reload the apps container
        ($ '#app_list_container').spin()
        $.get '/app/control_panel/apps', {}, (resp) ->
          ($ '#app_list_container').html(resp)
          ($ '#apps .popup').osPopup dialog: cpDialog, modal: true, keepindom: true 
    else
      # Error
      ($ '.os-dialog-container', cpDialog).prepend """
        <div class="error message">
          #{event.osEventData}
        </div>
      """

  ($ '.ssh-widget').osData event: 'ssh_form_return', onEvent: (event) ->
    ($ '.error', cpDialog).remove()
    if event.osEventStatus == 'success'
      # Success
      ($ '.current', this).text ( shorten event.osEventData.ssh, 20 )
      ($ '.popup', this).osPopup 'unpop'
      # update form elements with cleansed key
      $('#ssh_form_express_domain_ssh').val(event.osEventData.ssh)
      $('#express_domain_ssh').val(event.osEventData.ssh)
    else
      # Error
      ($ '.os-dialog-container', cpDialog).prepend """
        <div class="error message">
          #{event.osEventData}
        </div>
      """

  ($ '#apps').osData event: 'app_form_return', onEvent: (event) ->
    ($ '.error', this).remove()
    if event.osEventStatus == 'success'
      # update app table
      ($ '#app_list_container').html event.osEventData.app_table
      # repopup all the delete forms
      ($ '.popup', this).osPopup dialog: cpDialog, modal: true
      # hide any current popups that are showing
      cpDialog.osDialog 'hide'
      # hide or show form depending on app limit
      if event.osEventData.app_limit_reached
        ($ '.app-form', this).hide()
        ($ '.app-placeholder', this).show().text 'You have reached your limit of free apps.'
      else
        ($ '.app-form', this).show()
        ($ '.app-placeholder', this).hide()
    else
      # Error
      ($ '#new_express_app', this).before """
        <div class="error message">
          #{event.osEventData}
        </div>
      """


  # Set up spinners 
  ($ 'body').delegate 'form', 'submit', (event) ->
    ($ this).spin()
  ($ 'body').delegate 'form', 'ajax:complete', (event) ->
    ($ this).spin(false)

