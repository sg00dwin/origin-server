
// this executes all the "window.onload" type events
$j(function(){
  
// slideshow
	$j('.simpleSlideShow').slideShow({
	interval: 6
	});
// slideshow
	$j('.newsTicker').slideShow({
	interval: 2
	});

// Trigger "advanced" hover action in product promo boxes
  $j('.promo a').hover(
    function(event) {
      // Over event
      $j(this).closest('.promo').addClass('hover');
    },
    function(event) {
      // Out event
      $j('.promo').removeClass('hover');
    }
  );
  
// Tabs on product pages
  $j('#tab_navigation').tabs('.tab', {'tabs':'li'});

});
