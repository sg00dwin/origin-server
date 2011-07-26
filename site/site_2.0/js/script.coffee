# Compile with --bare flag #
$ ->
  # parallax effect on scroll #
  body = $ 'body'
  sm_pos = md_pos = lg_pos = 0
  top = ($ window).scrollTop()

  ($ window).scroll ->
    top_diff = ($ this).scrollTop() - top
    top = ($ this).scrollTop()
    
    sm_pos -= Math.round top_diff*1.5
    md_pos -= top_diff
    lg_pos -= Math.round top_diff*0.25
    
    body.css 'background-position', "-150px #{sm_pos}px, -150px #{md_pos}px, -150px #{lg_pos}px"

  # handle dialogs #
  dialogs = $ '.dialog'

  open_dialog = (dialog) -> 
    #Close any other open dialogs
    dialogs.hide()
    #Show given dialog
    dialog.show()

  close_dialog = (dialog) ->
    dialog.hide()
    
  #Close buttons
  close_btn = $ '.close_button' 
  #Sign up dialog
  signup = $ '#signup'
  #Sign in dialog
  signin = $ '#signin'

  ($ 'a.sign_up').click (event) ->
    event.preventDefault()
    open_dialog signup

  ($ 'a.sign_in').click (event) ->
    event.preventDefault()
    open_dialog signin
    
  close_btn.click (event) ->
    close_dialog ($ this).parent()

  # Scroll announcements #
  announcements = ($ '#announcements')
  ann_list = ($ 'ul', announcements)
  on_announcement = 0
  if ($ 'li', ann_list).length > 1
    ann_list.css 'position', 'relative'
    ann_height = ($ 'li', announcements).first().height()
    
    scroll_announcements = ->
      on_announcement++
      if on_announcement >= ($ 'li', ann_list).length
        on_announcement = 0
        ann_list.css 'top', 0
      else
        ann_list.css 'top', -1 * ann_height * on_announcement
    
    setInterval scroll_announcements, 10000





















