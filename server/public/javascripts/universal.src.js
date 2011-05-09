// File: site-wide js functionality

$(function(){
  
  var navigation, menus, labels, menu_widths, width_recalculated, expanded_menu, expanded_menu_id;
  
  /** 
   * Navigation bar animations
   */
  navigation = $('#nav');
  menus = $('ul', navigation);
  labels = $('.category', navigation);
  menu_widths = null;
  
  //Set expanded menu based on cookie
  expanded_menu_id = $.cookie('os_menu_expanded');
  //console.log(expanded_menu_id);
  //console.log(document.cookie);
  if (expanded_menu_id != null) {
    expanded_menu = menus.filter('#' + expanded_menu_id);
    //Check that expanded menu is not the default
    if (expanded_menu.hasClass('collapsed')) {
      //remove class from default expanded menu
      menus.filter('.expanded').removeClass('expanded').addClass('collapsed');
      labels.filter('.expanded').removeClass('expanded').addClass('collapsed');
      //add class to previously expanded menu
      expanded_menu.removeClass('collapsed').addClass('expanded');
      labels.filter('[data-category=' + expanded_menu_id + ']').removeClass('collapsed').addClass('expanded');
    }
  }
  
  //Initialize menus
  menus.each(function(){
    //console.log($(this).attr('id'));
    //Restrict height
    $(this).css('height', $(this).height());
    
    //Collapse those in need of it
    if ($(this).hasClass('collapsed')) {
      $(this).css({width:0});
    }
  });

  labels.click(function(){
    var id, menu;
    id = $(this).attr('data-category');
    menu = menus.filter('#' + id);
    if (menu.hasClass('collapsed')) {
      //Collapse all the other menus
      menus.each(function(){
        var label = labels.filter('[data-category="' + $(this).attr('id') + '"]');
        if ($(this) !== menu && $(this).hasClass('expanded')) {
          collapseMenu($(this), label);
        }
      });
      //Expand the menu
      expandMenu(menu, $(this));
    }
    else {
      collapseMenu(menu, $(this));
    }
  });
  
  function collapseMenu(menu, label) {
    menu.removeClass('expanded').addClass('collapsed');
    menu.stop().animate({width: 0}, 300,
    function(){
      label.removeClass('expanded').addClass('collapsed');
    });
  }
  
  function expandMenu(menu, label) {
    var id, menu_width;
    id = menu.attr('id');
    // If widths haven't already been calculated,
    // do so now.
    //
    // We're doing this here because calculating the
    // widths earlier can result in incorrect numbers
    // due to incomplete font loading.
    //
    // We're making the assumption that by the time
    // the user makes a decision to click on a menu,
    // the font file will have had enough time to load.
    if (menu_widths == null) {
      menu_widths = {};
      menus.each(function(){
        var total_width = 0;
        $(this).children('li').each(function(){
          // calculate width using the children 
          // since some menus are already collapsed
          total_width += $(this).width();
        });
        menu_widths[$(this).attr('id')] = total_width;
      });
      //console.log(menu_widths);
    }
    menu_width = menu_widths[id];
    //Set cookie to remember which menu was last expanded
    $.cookie('os_menu_expanded', id, {path: '/'});
    //console.log('expanded ' + id);
    //console.log(document.cookie);
    label.removeClass('collapsed').addClass('expanded');
    menu.removeClass('collapsed').addClass('expanded');
    menu.stop().animate({width: menu_width}, 300);
  }
});


