$(function() {
  var ann_height, ann_list, announcements, body, close_btn, close_dialog, dialogs, lg_pos, md_pos, nav, nav_top, on_announcement, open_dialog, scroll_announcements, signin, signup, sm_pos, sticky_css, top, unsticky_css;
  body = $('body');
  nav = $('header.universal > nav');
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
    return setInterval(scroll_announcements, 10000);
  }
});