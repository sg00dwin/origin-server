    <footer>
      <div id="footer-nav">
        <div class="container">
          <?php if ($footer){ print $footer; } ?>
          <?php
            $menu = menu_tree_page_data('menu-top-footer-menu');
            if ($menu) {
              print openshift_flat_menu_tree_output($menu);
            }
          ?>
        </div>
      </div>
      <section id="copyright">
        <div class="container">
          <a href="https://www.redhat.com/">
            <img src="<?php print openshift_assets_url(); ?>/redhat.png" alt="Red Hat">
          </a>
          <div class="pull-right"><?php print $footer_message; ?></div>
        </div>
      </section>
    </footer>
	<!-- Begin Eloqua Tracking -->
	<script type='text/javascript' src='https://www.redhat.com/j/elqNow/elqCfg.js'></script> 
	<script type='text/javascript' src='https://www.redhat.com/j/elqNow/elqImg.js'></script>
	<!-- End Eloqua Tracking -->
	<!-- Begin Google Analytics Tracking -->
	<script type="text/javascript" src="<?php print openshift_assets_url(); ?>/site/tracking.js"></script>
	<!-- End Google Analytics Tracking -->	
	<!-- Google Code for Remarketing tag -->
	<script type="text/javascript">
	/* <![CDATA[ */
	var google_conversion_id = 1007064360;
	var google_conversion_label = "amNWCJipqAQQqKqa4AM";
	var google_custom_params = window.google_tag_params;
	var google_remarketing_only = true;
	/* ]]> */
	</script>
	<script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
	</script>
	<noscript>
	<div style="display:inline;">
	<img height="1" width="1" style="border-style:none;" alt="" src="//googleads.g.doubleclick.net/pagead/viewthroughconversion/1007064360/?value=0&amp;label=amNWCJipqAQQqKqa4AM&amp;guid=ON&amp;script=0"/>
	</div>
	</noscript>
    
	<div style="display:none;"> <?php # FIXME remove after sprint 10 ?>
    <script src="<?php print $openshift_server_url; ?>/app/status/status.js?id=outage" type="text/javascript"></script>
    </div>
  </body>
<?php print $closure; ?>
</script>
</html>
