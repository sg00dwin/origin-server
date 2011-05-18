// File: site-wide js functionality

$(function(){
  
  var navigation, menus, labels, menu_widths, outage_notification, outage_notification_height;
  
  /**
   * Outage notification
   */
  outage_notification = $('#outage_notification');
  if (outage_notification.length > 0) {
    var show_outage_txt = '☟ Service Outages', 
        hide_outage_txt = '☝ Hide', 
        outage_notification_neg_height = '-' + outage_notification.outerHeight() + 'px',
        outage_animation_length = 700,
        outage_toggle,
        outage_toggle_state,
        overlay;
        
    // Initial css changes
    outage_notification.css({
      'position': 'absolute',
      'top': outage_notification_neg_height,
      'z-index': '1000'
    });
    
    // Add overlay
    $('body').append('<div id="overlay"></div>');
    overlay = $('#overlay');
    overlay.hide();
    
    // Add toggle
    outage_notification.append('<a href="#" id="outage_toggle">' + show_outage_txt + '</a>');
    outage_toggle = $('#outage_toggle');
    outage_toggle_state = 'hidden';
    
    // Toggle bindings
    outage_toggle.click(function(event) {
      event.preventDefault();
      if (outage_toggle_state == 'hidden') {
        show_notification();
      }
      else {
        hide_notification();
      }
    });
    
    function show_notification() {
      // Slide down notification
      outage_notification
        .css({'z-index': 2000})
        .stop()
        .animate({'top': 0}, outage_animation_length);
      // Fade in Overlay
      overlay.fadeIn(outage_animation_length);
      // Change toggle text
      outage_toggle.text(hide_outage_txt);
      outage_toggle_state = 'shown';
    }
    
    function hide_notification() {
      // Slide up notification
      outage_notification
        .css({'z-index': 1000})
        .stop()
        .animate({'top': outage_notification_neg_height}, outage_animation_length);
      // Scroll back to top of page
      $('html, body, document').stop().animate({scrollTop: 0}, 500); 
      // Fade out overlay
      overlay.fadeOut(outage_animation_length);
      // Change toggle text
      outage_toggle.text(show_outage_txt);
      outage_toggle_state = 'hidden';
    }
    
    // Check if notification has already been displayed
    if ($.cookie('outage_notification_displayed') != 'true') {
      // Display notification in 
      // an initially intrusive way 
      // so it can't be missed!
      outage_notification.css({'top': 0});
      outage_toggle.text(hide_outage_txt);
      outage_toggle_state = 'shown';
      
      //Set cookie
      $.cookie('outage_notification_displayed', 'true', {'expires': 14, 'path': '/app'});
    }
  }
  else {
    // Clear cookie if it exists
    $.cookie('outage_notification_displayed', null, {'path': '/app'});
  }
  
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
    var menu_width = menu_widths[menu.attr('id')];
    label.removeClass('collapsed').addClass('expanded');
    menu.removeClass('collapsed').addClass('expanded');
    menu.stop().animate({width: menu_width}, 300);
  }
});


