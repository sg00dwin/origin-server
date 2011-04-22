// File: Front page javascripts

$(function() {
  // slideshow
	$('.simpleSlideShow').slideShow({
    interval: 6
	});
// slideshow
	$('.newsTicker').slideShow({
    interval: 5
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
});
