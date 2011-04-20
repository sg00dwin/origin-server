// File: Front page slideshow script initialization

$(function() {
  // slideshow
	$('.simpleSlideShow').slideShow({
	interval: 6
	});
// slideshow
	$('.newsTicker').slideShow({
	interval: 2
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
});
