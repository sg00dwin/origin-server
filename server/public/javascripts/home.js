// File: Front page javascripts

$(function() {
  var promos;
  
  // slideshow
	$('.simpleSlideShow').slideShow({
    interval: 6
	});
  
  //-- Animate description over promo boxes --//
  //Initialize boxes
  promos = $('.promo');
  $('.description', promos).each(function() {
    //Set css properties
    $(this).css({
      'position': 'absolute',
      'bottom': '-300px', //off the edge of the container
      'background-color': 'rgba(51, 51, 51, .85)',
      'left': '55px'
    });
  });
  
  //trigger on mouseover
  promos.hover(
    function() {
      slideUp($(this).children('.description'));
    },
    function() {
      slideDown($(this).children('.description'));
  });
  
  //trigger on focus
  promos.focusin(function(event) {
    event.stopPropagation();
    slideUp($(this).find('.description'));
  });
  promos.focusout(function(event) {
      event.stopPropagation();
      slideDown($(this).find('.description'));
  });

  function slideUp(obj) {
    obj.stop().animate({'bottom': 0}, 500);
  }
  function slideDown(obj) {
    obj.stop().animate({'bottom': '-300px'}, 500);
  }
  
  
  // Trigger "advanced" hover action
  // in product promo boxes
  //$('.promo a').hover(
    //function(event) {
      //// Over event
      //$(this).closest('.promo').addClass('hover');
    //},
    //function(event) {
      //// Out event
      //$('.promo').removeClass('hover');
    //}
  //);
  
  // Fancybox
  //$('.fancybox').fancybox();
  
  //Accordians
  //$('#info').tabs('#info .section', {
    //tabs: 'h3.section-header',
    //effect: 'slide',
    //initialIndex: 0
  //});
});
