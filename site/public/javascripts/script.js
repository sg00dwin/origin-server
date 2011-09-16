/* DO NOT MODIFY. This file was compiled Wed, 14 Sep 2011 14:56:09 GMT from
 * /home/fotios/li/site/app/coffeescripts/script.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var ann_height, ann_list, announcements, body, close_btn, close_dialog, current, dialogs, links, login_complete, nav, nav_top, on_announcement, open_dialog, registration_complete, scroll_announcements, sections, signin, signup, sticky_css, top, unsticky_css;
    body = $('body');
    nav = ($('header.universal > nav')).first();
    nav_top = nav.offset().top;
    top = ($(window)).scrollTop();
    sticky_css = {
      position: 'fixed',
      top: 0,
      'z-index': 2000,
      width: '100%'
    };
    unsticky_css = {
      position: 'static'
    };
    ($(window)).scroll(function() {
      top = ($(this)).scrollTop();
      if (top > nav_top) {
        return nav.css(sticky_css);
      } else {
        return nav.css(unsticky_css);
      }
    });
    dialogs = $('.dialog');
    open_dialog = function(dialog) {
      dialogs.hide();
      return dialog.show();
    };
    close_dialog = function(dialog) {
      return dialog.hide();
    };
    close_btn = $('.close_button');
    signup = $('#signup');
    signin = $('#signin');
    ($('a.sign_up')).click(function(event) {
      event.preventDefault();
      return open_dialog(signup);
    });
    ($('a.sign_in')).click(function(event) {
      event.preventDefault();
      return open_dialog(signin);
    });
    close_btn.click(function(event) {
      return close_dialog(($(this)).parent());
    });
    login_complete = function(xhr, status) {
      var $err_div, json;
      json = $.parseJSON(status.responseText);
      console.log(json);
      $(this).parent().find('div.message.error').remove();
      $err_div = $('<div>').addClass('message error').hide().insertBefore(this);
      switch (status.status) {
        case 200:
          window.location.replace(json.redirectUrl);
          break;
        case 401:
          $err_div.text(json.error).show();
          break;
        default:
          $err_div.html(json.error || "Some unknown error occured,<br/> please try again.").show();
          return console.log('Some unknown AJAX error with the login', status.status);
      }
    };
    signin.find('form').bind('ajax:complete', login_complete);
    ($('#login-form')).find('form').bind('ajax:complete', login_complete);
    registration_complete = function(xhr, status) {
      var $err_div, form, json, messages;
      form = $(this);
      json = $.parseJSON(status.responseText);
      console.log("Reg complete, got JSON", json);
      $(this).parent().find('div.message.error').remove();
      $err_div = $('<div>').addClass('message error').hide().insertBefore(this);
      messages = $.map(json, function(k, v) {
        return k;
      });
      if (json['redirectUrl'] === void 0 || json['redirectUrl'] === null) {
        $.each(messages, function(i, val) {
          return $err_div.addClass('error').append($('<div>').html(val));
        });
        $err_div.show();
        if (typeof Recaptcha !== 'undefined') {
          return Recaptcha.reload();
        }
      } else {
        return window.location.replace(json['redirectUrl']);
      }
    };
    signup.find('form').bind('ajax:complete', registration_complete);
    ($('#new_web_user')).bind('ajax:complete', registration_complete);
    announcements = $('#announcements');
    ann_list = $('ul', announcements);
    on_announcement = 0;
    if (($('li', ann_list)).length > 1) {
      ann_list.css('position', 'relative');
      ann_height = ($('li', announcements)).first().height();
      scroll_announcements = function() {
        on_announcement++;
        if (on_announcement >= ($('li', ann_list)).length) {
          on_announcement = 0;
          return ann_list.css('top', 0);
        } else {
          return ann_list.css('top', -1 * ann_height * on_announcement);
        }
      };
      setInterval(scroll_announcements, 10000);
    }
    if (body.hasClass('product')) {
      links = $('.content nav a[href^=#]');
      sections = $('.content section');
      if (location.hash) {
        current = location.hash;
      } else {
        current = '#' + sections.first().attr('id');
      }
      sections.hide();
      links.removeClass('active');
      ($(current)).show();
      ($("a[href=" + current + "]")).addClass('active');
      links.click(function(event) {
        var target;
        event.preventDefault();
        target = ($(this)).attr('href');
        if (history.pushState) {
          history.pushState(null, null, target);
        } else {
          location.hash = target;
        }
        sections.hide();
        ($(target)).show();
        links.removeClass('active');
        return ($(this)).addClass('active');
      });
    }
    return ($('a.sign_up')).click(function(event) {
      var product;
      if (body.hasClass('express')) {
        product = 'Express';
      } else if (body.hasClass('flex')) {
        product = 'Flex';
      } else if (body.hasClass('home')) {
        product = 'Home';
      } else {
        product = 'Other';
      }
      return trackLink(this, product);
    });
  });
}).call(this);
