/* DO NOT MODIFY. This file was compiled Thu, 17 Nov 2011 21:57:46 GMT from
 * /home/aboone/Source/li/site/app/coffeescripts/script.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var ann_height, ann_list, announcements, body, current, links, nav, nav_top, on_announcement, scroll_announcements, sections, sticky_css, stuck, top, unsticky_css;
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
    return ($('a.sign_up')).click(function(event) {
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
  });
}).call(this);
