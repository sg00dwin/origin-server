$(function() {
  var ann_height, ann_list, announcements, body, current, links, nav, nav_top, on_announcement, scroll_announcements, sections, sticky_css, top, unsticky_css;
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