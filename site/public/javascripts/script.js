/* DO NOT MODIFY. This file was compiled Wed, 25 Jan 2012 15:49:29 GMT from
 * /home/clayton/code/li/site/app/coffeescripts/script.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var ann_height, ann_list, announcements, body, current, hide_notification, hide_outage_txt, links, on_announcement, outage_animation_length, outage_notification, outage_notification_neg_height, outage_toggle, outage_toggle_state, overlay, scroll_announcements, section, section_selector, sections, show_notification, show_outage_txt;
    body = $('body');
    $('header.universal nav li a').textOverflow();
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
      section_selector = '.content section';
      sections = $(section_selector);
      if (location.hash) {
        section = location.hash.replace(/[^a-z0-9_\-]/gi, '');
        current = $('#' + section);
        if (!current.is(section_selector)) {
          current = current.parents(section_selector);
        }
      }
      if (!current || current.length !== 1) {
        current = sections.first();
      }
      sections.hide();
      links.removeClass('active');
      current.show();
      ($("a[href=#" + (current.attr('id')) + "]")).addClass('active');
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
      show_outage_txt = '&#9759; Service Outages';
      hide_outage_txt = '&#9757; Hide';
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
        outage_toggle.html(hide_outage_txt);
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
        outage_toggle.html(show_outage_txt);
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
