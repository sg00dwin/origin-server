//JQuery will interfere with prototype unless
$j = jQuery.noConflict();

//JQuery can be referenced by $j from now on

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

});
