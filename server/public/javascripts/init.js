
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

  // Trigger "advanced" hover action
  // in product promo boxes
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
  
//-- Client-side validation --//
  
  //Login form
  $j('#login-form form').validate({
    rules: {
      login: {
        required: true,
      },
      password: {
        required: true
      }
    }
  });
  
  //Register form
  $j('#new_web_user').validate({
    rules: {
      'web_user[email_address]': {
        required: true,
        email: true
      },
      'web_user[password]': {
        required: true,
        minlength: 6
      },
      'web_user[password_confirmation]': {
        required: true,
        equalTo: '#web_user_password'
      }
    }
  });

});
