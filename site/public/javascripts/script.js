$(function() {
  var ann_height, ann_list, announcements, body, current, lg_pos, links, md_pos, nav, nav_top, on_announcement, scroll_announcements, sections, sm_pos, sticky_css, top, unsticky_css;
  body = $('body');
  nav = ($('header.universal > nav')).first();
  nav_top = nav.offset().top;
  sm_pos = md_pos = lg_pos = 0;
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
    var top_diff;
    top_diff = ($(this)).scrollTop() - top;
    top = ($(this)).scrollTop();
    sm_pos -= top_diff;
    md_pos -= Math.round(top_diff * 0.5);
    lg_pos -= Math.round(top_diff * 0.25);
    body.css('background-position', "-150px " + sm_pos + "px, -150px " + md_pos + "px, -150px " + lg_pos + "px");
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
    return links.click(function(event) {
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
});