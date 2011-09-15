/* DO NOT MODIFY. This file was compiled Wed, 14 Sep 2011 13:59:19 GMT from
 * /home/fotios/li/site/app/coffeescripts/control_panel.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var app_form, close_spinner, domain_action, domain_edit_button, domain_form_container, domain_form_replacement, domain_update_form, interval, multibgs, promo_text, setup_domain_update_form, show_spinner, spin_x, spinner, spinner_closebtn, spinner_text, spinny, start_spinner_animation, stop_spinner_animation, submit_buttons, timeout, toggle_domain_update_form, update_values, verification_max_tries;
    domain_action = ($('#domain_form form')).hasClass('update') ? 'update' : 'create';
    domain_form_container = $('#domain_form');
    domain_update_form = $('form.update');
    domain_form_replacement = '';
    domain_edit_button = $('.edit_domain');
    app_form = $('#app_form');
    submit_buttons = $('input.create');
    verification_max_tries = 5;
    multibgs = ($('html')).hasClass('multiplebgs');
    promo_text = {
      php: "In the meantime, check out these videos\nfor easy ways to use your new OpenShift PHP app:\n<ul>\n  <li>\n    <figure>\n      <a href=\"http://youtu.be/SabOGub2jiE\" target=\"_blank\">\n        <img src=\"/app/images/video_stills/mediawiki.png\" alt=\"Mediawiki video\" />\n        <figcaption>Getting started with MediaWiki</figcaption>\n      </a>\n    </figure>\n  </li>\n  <li>\n    <a href=\"http://youtu.be/6TSxAE2K3QM\" target=\"_blank\">\n      <figure>\n        <img src=\"/app/images/video_stills/drupal.png\" alt=\"Drupal video\" />\n        <figcaption>Getting started with Drupal</figcaption>\n      </figure>\n    </a>\n  </li>\n</ul>",
      wsgi: "In the meantime, check out these blog posts on how to deploy popular python frameworks on your new OpenShift Python app:\n<ul>\n  <li>\n    <a href=\"https://www.redhat.com/openshift/blogs/deploying-a-pyramid-application-in-a-virtual-python-wsgi-environment-on-red-hat-openshift-expr\" target=\"_blank\">Deploy a Pyramid app</a>\n  </li>\n  <li>\n    <a href=\"https://www.redhat.com/openshift/blogs/deploying-turbogears2-python-web-framework-using-express\" target=\"_blank\">Deploy the TurboGears2 framework</a>\n  </li>\n</ul>",
      rack: "In the meantime, check out these articles on using\npopular Ruby frameworks on OpenShift:\n<ul>\n    <li>\n      <a href=\"https://www.redhat.com/openshift/kb/kb-e1005-ruby-on-rails-express-quickstart-guide\" target=\"_blank\">Ruby on Rails quickstart guide</a>\n    </li>\n    <li>\n      <a href=\"https://www.redhat.com/openshift/kb/kb-e1009-deploying-a-sinatra-application-on-openshift-express\" target=\"_blank\">Deploy a Sinatra app</a>\n    </li>\n</ul>\n",
      perl: "In the meantime, check out <a href=\"https://www.redhat.com/openshift/kb/kb-e1013-how-to-onboard-a-perl-application\" target=\"_blank\">this article</a> to get started with your new OpenShift Perl app.",
      jbossas: "In the meantime, check out these videos on getting started using Java\nwith JBossAS 7 on OpenShift:\n<ul>\n    <li>\n      <figure>\n        <a href=\"http://vimeo.com/27546106\" target=\"_blank\">\n          <img src=\"/app/images/video_stills/play.png\" alt=\"Play framework video\" />\n          <figcaption>Using the Play framework</figcaption>\n        </a>\n      </figure>\n    </li>\n    <li>\n      <figure>\n        <a href=\"http://vimeo.com/27502795\" target=\"_blank\">\n          <img src=\"/app/images/video_stills/spring.png\" alt=\"Spring framework video\" />\n          <figcaption>Running a Spring application</figcaption>\n        </a>\n      </figure>\n    </li>\n</ul>",
      jenkins: ''
    };
    ($('body')).append("<div id=\"spinner\">\n  <div id=\"spinner-text\">\n    Working...\n  </div>\n  <div id=\"spinning\"></div>\n</div>");
    spinner = $('#spinner');
    spinner_text = $('#spinner-text');
    spinny = $('#spinning');
    spinner_closebtn = $('.close', spinner);
    spinner.hide();
    spin_x = 0;
    interval = '';
    timeout = '';
    show_spinner = function(show_text) {
      if (show_text == null) {
        show_text = 'Working...';
      }
      spinner.removeClass('stop-spinning');
      spinny.css('background-position', '0px bottom');
      start_spinner_animation();
      spinner_text.text(show_text);
      return spinner.show();
    };
    close_spinner = function(closing_text, time_to_close) {
      if (closing_text == null) {
        closing_text = false;
      }
      if (time_to_close == null) {
        time_to_close = 5000;
      }
      if (!closing_text) {
        clearTimeout(timeout);
        stop_spinner_animation();
        return spinner.hide();
      } else {
        clearTimeout(timeout);
        spinner.addClass('stop-spinning');
        spinner_text.html(closing_text);
        return timeout = setTimeout((function() {
          stop_spinner_animation();
          spinner.hide();
          return spinner.removeClass('stop-spinning');
        }), time_to_close);
      }
    };
    start_spinner_animation = function() {
      if (multibgs) {
        return interval = setInterval((function() {
          spin_x += 5;
          return spinny.css({
            'background-position': "center center, " + spin_x + "px bottom"
          });
        }), 50);
      } else {
        return interval = setInterval((function() {
          spin_x += 5;
          return spinny.css({
            'background-position': "" + spin_x + "px bottom"
          });
        }), 50);
      }
    };
    stop_spinner_animation = function() {
      spin_x = 0;
      return clearInterval(interval);
    };
    setup_domain_update_form = function() {
      var namespace, ssh;
      namespace = ($('#express_domain_namespace')).val();
      ssh = (($('#express_domain_ssh')).val().slice(0, 20)) + '...';
      domain_form_container.append("<dl id=\"domain_form_replacement\">\n  <dt>Your namespace:</dt>\n  <dd id=\"show_namespace\">" + namespace + "</dd>\n  <dt>Your ssh key:</dt>\n  <dd id=\"show_ssh\">" + ssh + "</dd>\n  <a class=\"button edit_domain\">Edit</a>\n</dl>\n");
      domain_update_form.append("<a class=\"button edit_domain\">Cancel</a>");
      domain_form_replacement = $('#domain_form_replacement');
      if (domain_update_form.hasClass('hidden')) {
        return domain_update_form.hide();
      } else {
        return domain_form_replacement.hide();
      }
    };
    if (domain_update_form.length > 0) {
      setup_domain_update_form();
    }
    update_values = function() {
      var ns, sh;
      ns = (typeof namespace === "function" ? namespace(namespace) : void 0) ? void 0 : ($('#express_domain_namespace')).val();
      sh = (typeof ssh === "function" ? ssh(ssh) : void 0) ? void 0 : ($('#express_domain_ssh')).val();
      ($('#show_namespace')).text(ns);
      return ($('#show_ssh')).text(sh);
    };
    toggle_domain_update_form = function() {
      if (domain_update_form.hasClass('hidden')) {
        domain_update_form.removeClass('hidden');
        domain_update_form.show();
        return domain_form_replacement.hide();
      } else {
        update_values();
        domain_update_form.addClass('hidden');
        domain_update_form.hide();
        return domain_form_replacement.show();
      }
    };
    /*
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
        
      */
    spinner_closebtn.live('click', function(event) {
      return close_spinner('', 100);
    });
    ($('input.create', domain_form_container)).live('click', function(event) {
      switch (domain_action) {
        case 'update':
          return show_spinner('Updating your domain...');
        case 'create':
          return show_spinner('Creating your domain...');
      }
    });
    ($('input.create', app_form)).live('click', function(event) {
      return show_spinner('Creating your app...');
    });
    domain_update_form.live('switch_create_to_update', setup_domain_update_form);
    domain_update_form.live('submission_returned', function(event) {
      return close_spinner();
    });
    domain_update_form.live('successful_submission', toggle_domain_update_form);
    domain_edit_button.live('click', toggle_domain_update_form);
    app_form.live('submission_returned', function(event) {
      return close_spinner();
    });
    return app_form.live('successful_submission', function(event) {
      return close_spinner("\n<p>\n  <em>\n    Depending on where you live, it may take up to 15 minutes for your app to be live.\n  </em>\n</p>\n<p>\n  " + promo_text[cartridge] + "\n</p>\n<a href=\"#\" class=\"close\" title = \"Close this dialog\">\n  <img src = \"/app/images/close_button.png\">\n</a>", 600000);
    });
  });
}).call(this);
