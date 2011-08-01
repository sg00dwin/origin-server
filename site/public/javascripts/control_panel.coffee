$ ->
  form_container = $ '#domain_form'
  update_form = $ 'form.update'
  form_replacement = ''
  edit_button = $ '#edit_domain'
  
  setup_update_form = ->
    namespace = ($ '#express_domain_namespace').val()
    ssh = (($ '#express_domain_ssh').val().slice 0, 20) + '...'
    form_container.append """
      <dl id="form_replacement">
        <dt>Your namespace:</dt>
        <dd id="show_namespace">#{namespace}</dd>
        <dt>Your ssh key:</dt>
        <dd id="show_ssh">#{ssh}</dd>
        <a class="button" id="edit_domain">Edit</a>
      </dl>
      
    """
    form_replacement = $ '#form_replacement'
    
    if update_form.hasClass 'hidden'
      update_form.hide()
    else
      form_replacement.hide()
  
  if update_form.length > 0
    setup_update_form()

  update_values = ->
    namespace = ($ '#express_domain_namespace').val()
    ssh = (($ '#express_domain_ssh').val().slice 0, 20) + '...'
    ($ '#show_namespace').text namespace
    ($ '#show_ssh').text ssh

  toggle_update_form = ->
    if update_form.hasClass 'hidden'
      update_form.removeClass 'hidden'
      update_form.show()
      form_replacement.hide()
    else
      update_values()
      update_form.addClass 'hidden'
      update_form.hide()
      form_replacement.show()

  update_form.live 'switch_create_to_update', setup_update_form
  update_form.live 'successful_submission', toggle_update_form
  edit_button.live 'click', toggle_update_form
