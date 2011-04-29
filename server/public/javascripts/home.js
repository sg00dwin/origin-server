// File: Front page javascripts

$(function() {
  // slideshow
	$('.simpleSlideShow').slideShow({
    interval: 6
	});
  
  // Trigger "advanced" hover action
  // in product promo boxes
  $('.promo a').hover(
    function(event) {
      // Over event
      $(this).closest('.promo').addClass('hover');
    },
    function(event) {
      // Out event
      $('.promo').removeClass('hover');
    }
  );
  
  // Fancybox
  $('.fancybox').fancybox();
  
  //Accordians
  //$('#info').tabs('#info .section', {
    //tabs: 'h3.section-header',
    //effect: 'slide',
    //initialIndex: 0
  //});
});
