$ ->
  domain_form_container = $ '#domain_form'
  domain_update_form = $ 'form.update'
  domain_form_replacement = ''
  domain_edit_button = $ '.edit_domain'
  app_form = $ '#app_form'
  submit_buttons = $ 'input.create'
  verification_max_tries = 5
  promo_text =
    php: """
      In the meantime, check out these videos
      for easy ways to use your new OpenShift PHP app:
      <ul>
        <li>
          <figure>
            <a href="http://youtu.be/SabOGub2jiE">
              <img src="/app/images/video_stills/mediawiki.png" alt="Mediawiki video" />
              <figcaption>Getting started with MediaWiki</figcaption>
            </a>
          </figure>
        </li>
        <li>
          <a href="http://youtu.be/6TSxAE2K3QM">
            <figure>
              <img src="/app/images/video_stills/drupal.png" alt="Drupal video" />
              <figcaption>Getting started with Drupal</figcaption>
            </figure>
          </a>
        </li>
      </ul>
    """
    wsgi: """
      In the meantime, check out these blog posts for steps to deploy great python framework on your new OpenShift Python app:
      <ul>
        <li>
          <a href="https://www.redhat.com/openshift/blogs/deploying-a-pyramid-application-in-a-virtual-python-wsgi-environment-on-red-hat-openshift-expr">Deploy a Pyramid app</a>
        </li>
        <li>
          <a href="https://www.redhat.com/openshift/blogs/deploying-turbogears2-python-web-framework-using-express">Deploy the TurboGears2 framework</a>
        </li>
      </ul>
    """
    rack: """
      In the meantime, check out these articles on using
      popular Ruby frameworks on OpenShift:
      <ul>
          <li>
            <a href="https://www.redhat.com/openshift/kb/kb-e1005-ruby-on-rails-express-quickstart-guide">Ruby on Rails quickstart guide</a>
          </li>
          <li>
            <a href="https://www.redhat.com/openshift/kb/kb-e1009-deploying-a-sinatra-application-on-openshift-express">Deploy a Sinatra app</a>
          </li>
      </ul>
      
    """
    perl: """
      In the meantime, check out <a href="https://www.redhat.com/openshift/kb/kb-e1013-how-to-onboard-a-perl-application">this article</a> to get started with your new OpenShift Perl app.
    """
    jbossas: """
      In the meantime, check out these videos on getting started using Java
      with JBossAS 7 on OpenShift:
      <ul>
          <li>
            <figure>
              <a href="http://vimeo.com/27546106">
                <img src="/app/images/video_stills/play.png" alt="Play framework video" />
                <figcaption>Using the Play framework</figcaption>
              </a>
            </figure>
          </li>
          <li>
            <figure>
              <a href="http://vimeo.com/27502795">
                <img src="/app/images/video_stills/spring.png" alt="Spring framework video" />
                <figcaption>Running a Spring application</figcaption>
              </a>
            </figure>
          </li>
      </ul>
    """

  
  # Setup "spinner"
  ($ 'body').append """
    <div id="spinner">
      <div id="spinner-text">
        Working...
      </div>
      <div id="spinning"></div>
    </div>
  """
  spinner = $ '#spinner'
  spinner_text = $ '#spinner-text'
  spinny = $ '#spinning'
  spinner.hide()
  spin_x = 0
  interval = ''
  
  show_spinner = (show_text = 'Working...') ->
    spinny.css 'background-position', '0px bottom'
    animate_spinner()
    spinner_text.text show_text
    spinner.show()
  
  close_spinner = (closing_text = false, time_to_close = 5000) ->
    if not closing_text
      stop_spinner_animation()
      spinner.hide()
    else
      spinner.addClass 'stop-spinning'
      spinner_text.html closing_text
      setTimeout ( ->
        stop_spinner_animation()
        spinner.hide()
        spinner.removeClass 'stop-spinning'
      ), time_to_close
  
  animate_spinner = ->
    interval = setInterval ( ->
      spin_x += 5
      spinny.css 'background-position', "#{spin_x}px bottom"
    ), 50
  
  stop_spinner_animation = ->
    spin_x = 0
    clearInterval(interval)
  
  setup_domain_update_form = ->
    namespace = ($ '#express_domain_namespace').val()
    ssh = (($ '#express_domain_ssh').val().slice 0, 20) + '...'
    domain_form_container.append """
      <dl id="domain_form_replacement">
        <dt>Your namespace:</dt>
        <dd id="show_namespace">#{namespace}</dd>
        <dt>Your ssh key:</dt>
        <dd id="show_ssh">#{ssh}</dd>
        <a class="button edit_domain">Edit</a>
      </dl>
      
    """
    domain_update_form.append """
    <a class="button edit_domain">Cancel</a>
    """
    domain_form_replacement = $ '#domain_form_replacement'
    
    if domain_update_form.hasClass 'hidden'
      domain_update_form.hide()
    else
      domain_form_replacement.hide()
  
  if domain_update_form.length > 0
    setup_domain_update_form()

  update_values = ->
    namespace = ($ '#express_domain_namespace').val()
    ssh = (($ '#express_domain_ssh').val().slice 0, 20) + '...'
    ($ '#show_namespace').text namespace
    ($ '#show_ssh').text ssh

  toggle_domain_update_form = ->
    if domain_update_form.hasClass 'hidden'
      domain_update_form.removeClass 'hidden'
      domain_update_form.show()
      domain_form_replacement.hide()
    else
      update_values()
      domain_update_form.addClass 'hidden'
      domain_update_form.hide()
      domain_form_replacement.show()
  
  verify_app = (app_url) ->
    sleep_time = 1
    found_app = false
    attempt = 0

    look_for_app = ->
      console.log 'Trying app url', app_url, 'attempt number', attempt
      spinner.text "Verifying app. Attempt #{(attempt + 1)} of #{verification_max_tries}"
      $.ajax (
        url: check_url
        data:
          url: app_url
        dataType: 'json'
        success: (data, textStatus, jqXHR)->
          console.log 'success! status', textStatus, 'data', data
          if data.status == '200' and data.body == '1'
            found_app = true
            console.log 'Found app w00t!'
            ($ window).trigger 'app_found'
          else
            ($ window).trigger('try_app_again')
        error: ->
          ($ window).trigger('try_app_again')
      )
    
    ($ window).bind 'try_app_again', ->
      attempt++
      if attempt < verification_max_tries
        sleep_time *= 2
        console.log 'Could not find app, trying again in', sleep_time, 'seconds'
        spinner.text "Verifying app. Will try again in #{sleep_time} seconds."
        setTimeout look_for_app, sleep_time*1000
      else
        console.log 'Unable to verify app'
        ($ window).trigger 'app_not_found'

    ($ window).bind 'app_not_found', ->
      close_spinner "Oh noes! We couldn't verify that your app is live! Wait a few more minutes and try it at the given url."
    
    ($ window).bind 'app_found', ->
      close_spinner "Congrats! Your app is live! Have fun!"
      
    look_for_app()
    
  
  # Event handling
  
  # Show spinners on form submission
  ($ 'input.create', domain_form_container).live 'click', (event) ->
    show_spinner 'Updating your domain...'
    
  ($ 'input.create', app_form).live 'click', (event) ->
    show_spinner 'Creating your app...'
  
  domain_update_form.live 'switch_create_to_update', setup_domain_update_form
  
  domain_update_form.live 'submission_returned', (event) ->
    close_spinner()
  
  domain_update_form.live 'successful_submission', toggle_domain_update_form
    
  domain_edit_button.live 'click', toggle_domain_update_form

  app_form.live 'successful_submission', (event) ->
    close_spinner """
      <p>
        <em>
          Depending on where you live, it may take up to 15 minutes for your app to be live.
        </em>
      </p>
      <p>
        #{promo_text[cartridge]}
      </p>
    """, 15000
    #spinner.text 'Verifying your app is available...'
    #verify_app(current_app_url)
