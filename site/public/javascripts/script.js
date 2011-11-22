/* DO NOT MODIFY. This file was compiled Tue, 22 Nov 2011 17:50:50 GMT from
 * /Users/alex/Source/li/site/app/coffeescripts/script.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var ann_height, ann_list, announcements, body, current, hide_notification, hide_outage_txt, links, nav, nav_top, on_announcement, outage_animation_length, outage_notification, outage_notification_neg_height, outage_toggle, outage_toggle_state, overlay, scroll_announcements, sections, show_notification, show_outage_txt, sticky_css, stuck, top, unsticky_css;
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
    stuck = false;
    ($(window)).scroll(function() {
      var should_stick;
      top = ($(this)).scrollTop();
      should_stick = top > nav_top;
      if (should_stick && !stuck) {
        nav.css(sticky_css);
        ($('body > section:first')).css('marginTop', nav.height() + 'px');
        return stuck = true;
      } else if (stuck && !should_stick) {
        nav.css(unsticky_css);
        ($('body > section:first')).css('marginTop', 0);
        return stuck = false;
      }
    });
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
    ($('a.sign_up')).click(function(event) {
      var product;
      if (typeof trackLink !== "undefined" && trackLink !== null) {
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
      }
    });
    outage_notification = $('#outage_notification');
    if (outage_notification.length > 0) {
      show_outage_txt = '☟ Service Outages';
      hide_outage_txt = '☝ Hide';
      outage_notification_neg_height = '-' + outage_notification.outerHeight() + 'px';
      outage_animation_length = 1000;
      outage_notification.css({
        position: 'absolute',
        top: outage_notification_neg_height,
        left: 0,
        zIndex: 1000
      });
      ($('body')).append('<div id="overlay"></div>');
      overlay = $('#overlay');
      overlay.hide();
      outage_notification.append('<a href="#" id="outage_toggle">' + show_outage_txt + '</a>');
      outage_toggle = $('#outage_toggle');
      outage_toggle_state = 'hidden';
      show_notification = function() {
        outage_notification.css('z-index', 2000);
        outage_notification.stop();
        outage_notification.animate({
          top: 0
        }, outage_animation_length);
        overlay.show();
        outage_toggle.text(hide_outage_txt);
        return outage_toggle_state = 'shown';
      };
      hide_notification = function() {
        var containers;
        outage_notification.css('z-index', 1000);
        outage_notification.stop();
        outage_notification.animate({
          top: outage_notification_neg_height
        }, outage_animation_length);
        containers = $('html, body, document');
        containers.stop();
        containers.animate({
          scrollTop: 0
        }, outage_animation_length);
        overlay.hide();
        outage_toggle.text(show_outage_txt);
        return outage_toggle_state = 'hidden';
      };
      outage_toggle.click(function(event) {
        event.preventDefault();
        if (outage_toggle_state === 'hidden') {
          return show_notification();
        } else {
          return hide_notification();
        }
      });
      if ('true' !== ($.cookie('outage_notification_displayed'))) {
        show_notification();
        return $.cookie('outage_notification_displayed', 'true', {
          'expires': 14,
          'path': '/app'
        });
      }
    } else {
      return $.cookie('outage_notification_displayed', null, {
        'path': '/app'
      });
    }
  });
}).call(this);
