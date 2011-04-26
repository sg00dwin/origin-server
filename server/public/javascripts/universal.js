// File: site-wide js functionality

$(function(){
  
  var navigation, menus, labels, menu_widths;
  
  /** 
   * Navigation bar animations
   */
  navigation = $('#nav');
  menus = $('ul', navigation);
  labels = $('.category', navigation);
  
  //Initialize menus
  menu_widths = {};
  menus.each(function(){
    //console.log($(this).attr('id'));
    //Record width
    menu_widths[$(this).attr('id')] = $(this).width();
    //Restrict height
    $(this).css('height', $(this).height());
    
    //Collapse those in need of it
    if ($(this).hasClass('collapsed')) {
      $(this).css({width:0});
    }
  });
  //console.log(menu_widths);
  
  labels.click(function(){
    var id, menu;
    id = $(this).attr('data-category');
    menu = menus.filter('#' + id);
    if (menu.hasClass('collapsed')) {
      //Collapse all the other menus
      menus.each(function(){
        var label = labels.filter('[data-category="' + $(this).attr('id') + '"]');
        if ($(this) != menu && $(this).hasClass('expanded')) {
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
    var menu_width = menu_widths[menu.attr('id')];
    label.removeClass('collapsed').addClass('expanded');
    menu.removeClass('collapsed').addClass('expanded');
    menu.stop().animate({width: menu_width}, 300);
  }
});


