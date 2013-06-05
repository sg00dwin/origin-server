<?php 
  $block = module_invoke('block', 'block', 'view', '4'); 
  $messaging = $block['content'];

?><?php include 'page_header.inc' ?>

<header>
  <?php include 'page_top.inc' ?>
  <?php include 'page_nav.inc' ?>
</header>

<div id="home" class="">
  <div class="container">
    <?php $block = module_invoke('block', 'block', 'view', '6'); print $block['content']; ?>

    <div id="buzz" class="section-base">
      <div class="container">
        <div class="row row-buzz">
          <div class="span12">
            <div class="column-buzz">
              <h1>
                What others are saying
              </h1>
              <hr>
              <div class="row-fluid">
                <div id="buzz-testimonials" class="span5"><?php $block = module_invoke('block', 'block', 'view', '3'); print $block['content']; ?></div>
                <div class="span1">&nbsp;</div>
                <div id="buzz-retweets" class="span6"><?php print _redhat_frontpage_load_retweets(); ?></div>
              </div>

              <div class="row-fluid buzz-actions">
                <div class="span6"><a class="link-with-action" href="/products#why-openshift"><strong>Why</strong> OpenShift?</a></div>
                <div class="span6">
                  <div class="align-right"><a class="link-with-action" href="http://www.twitter.com/#!/openshift"><strong>Follow</strong> OpenShift</a></div>
                  <div class="align-right"><a class="link-with-action" href="http://twitter.com/#!/search/%23OpenShift"><strong>More</strong> #OpenShift buzz</a></div>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script type="text/javascript">
  $.fn.setAllToMaxHeight = function(){
    return this.height( Math.max.apply(this, $.map( this , function(e){ return $(e).height() }) ) );
  }
  $(document).ready(function() {
    var products = $('li', '#products');
    products.on('mouseover', function() {
      products.removeClass('active');
      $(this).addClass('active');
    });
    var productDescriptions = $('#products li p');
    productDescriptions.setAllToMaxHeight();
    $(window).resize(function() {
      productDescriptions.css('height', 'auto');
      productDescriptions.setAllToMaxHeight();
    });
    $(window).scroll(function() {
      var x = $(this).scrollTop();
      if ($(window).width() > 978) {
        $('body.home2 #home').css('background-position', (65 - parseInt(x / 50)) + '% ' + (50 + parseInt(x / 50)) + '%');
      }
      else if ($(window).width() < 979 && $(window).width() > 800) {
        $('body.home2 #home').css('background-position', (75 - parseInt(x / 25)) + '% ' + (53 + parseInt(x / 50)) + '%');
      }
    });
  });
</script>
<?php include 'page_footer.inc' ?>