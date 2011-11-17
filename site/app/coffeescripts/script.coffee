# Compile with --bare flag #
$ = jQuery

$ ->

## Scroll effects ##
  # nav sticks to top when scrolling off page #
  # parallax effect on scroll (undone for now) #
  body = $ 'body'
  nav = ($ 'header.universal > nav').first()
  nav_top = nav.offset().top
  #sm_pos = md_pos = lg_pos = 0
  top = ($ window).scrollTop()
    
  sticky_css =
    position: 'fixed'
    top: 0
    'z-index': 2000
    width: '100%'
  unsticky_css =
    position: 'static'

  stuck = false

  ($ window).scroll ->
    # parallax effect #
    #top_diff = ($ this).scrollTop() - top
    top = ($ this).scrollTop()
    
    #sm_pos -= top_diff
    #md_pos -= Math.round top_diff*0.5
    #lg_pos -= Math.round top_diff*0.25
    
    #body.css 'background-position', "-150px #{sm_pos}px, -150px #{md_pos}px, -150px #{lg_pos}px"
    
    # sticky nav #
    # check if nav is supposed to be off the page
    should_stick = top > nav_top

    if should_stick and !stuck
      nav.css sticky_css
      ($ 'body > section:first').css 'marginTop', nav.height() + 'px'
      stuck = true
    else if stuck and !should_stick
      nav.css unsticky_css
      ($ 'body > section:first').css 'marginTop', 0
      stuck = false
      
## Announcements ##
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

## Product page ##
  if body.hasClass 'product'
    links = $ '.content nav a[href^=#]'
    sections = $ '.content section'
    
    # get current section
    if location.hash
      current = location.hash
    else
      current = '#' + sections.first().attr('id')
    
    # hide sections
    sections.hide()
    links.removeClass 'active'
    # show current section 
    ($ current).show()
    ($ "a[href=#{current}]").addClass 'active'
    
    # hide toc in doc iframe
    # document.domain = 'redhat.com'
    # frame = ($ ($ '#docs').find('iframe')[0].contentDocument)
    # toc = $ '#tocdiv', frame
    # console.log('frame', frame)
    # console.log('toc', toc)
    
    # change sections based on clicked link
    links.click (event) ->
      event.preventDefault()
      
      target = ($ this).attr('href')
      
      # prevent annoying flash for better browsers
      if history.pushState
        history.pushState null, null, target
      else
        location.hash = target
      
      sections.hide()
      ($ target).show()
      
      #change link class
      links.removeClass 'active'
      ($ this).addClass 'active'
    
## Omniture click tracking ##
  ($ 'a.sign_up').click (event) ->
    if trackLink?
      if body.hasClass 'express'
        product = 'Express'
      else if body.hasClass 'flex'
        product = 'Flex'
      else if body.hasClass 'home'
        product = 'Home'
      else
        product = 'Other'
      
      trackLink this, product






