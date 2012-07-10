<!DOCTYPE html>
<!--[if lt IE 7]> <html class="ie6 no-js" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="ie7 no-js" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="ie8 no-js" lang="en"> <![endif]-->
<!--[if gt IE 8]><!-->
<html class='no-js' lang='en'>
  <!--<![endif]-->
  <head>
    <meta charset='utf-8'>
    <meta content='IE=edge,chrome=1' http-equiv='X-UA-Compatible'>
    <?php print $head; ?>
	  <title><?php print $head_title; ?></title>
    <?php 
      // reference CSS files directly from openshift
      //print_r(menu_get_active_trail());
      global $base_url;
      global $base_root;
      if (empty($sidebar_left)) {
        if (empty($sidebar_right)) { $layout = 'none'; }
        else { $layout = 'right'; }
      }
      else {
        if (empty($sidebar_right)) { $layout = 'left'; }
        else { $layout = 'both'; }
      }
    ?>
    <link type="image/png" rel="shortcut icon" href="/app/images/favicon-32.png"></link>
    <link type="text/css" rel="stylesheet" href="/app/stylesheets/overpass.css"></link>
    <script src="/app/javascripts/modernizr.min.js" type="text/javascript"></script>
    <link type="text/css" rel="stylesheet" href="/app/stylesheets/common.css"></link>
    <link type="text/css" rel="stylesheet" href="/app/stylesheets/site.css"></link>
	  <?php print $styles; ?>
	  <?php print $scripts; ?>
    <meta content='' name='description'>
    <meta content='' name='author'>
    <meta content='width=device-width, initial-scale=1.0' name='viewport'>
    <meta name="csrf-param" content="authenticity_token"/>
    <meta name="csrf-token" content="+CyXrdA5MZFVwLks73ibMfRiwRE+ixICENvvHms1Exk="/>
  </head>
  <body class='community'>
    <header>
      <div id="top" class="section-top">
        <div class="container">
        	<a title="Track open issues on the OpenShift status page" style="display:none;" id="outage" class="btn btn-small btn-warning" href="/app/status">Status</a>
          <div class="pull-left"><a href="http://makara.nurturehq.com/makara/newsletter_signup.html">Newsletter Sign Up</a></div>
          <div class="pull-right login">
          
          <form action="/community/search/node" method="get" id="search-top">
             <input name="keys" class="search-query" type="text" placeholder="SEARCH">
             <button type="submit" class="search" value="Search"></button>
             <?php print $search['hidden']; ?>
          </form>

            <?php
            global $user;
            
            if ( $user->uid ) {
              $logout_url = variable_get('redhat_sso_logout_url', $base_url . '/logout');
              $logout_url .= '?then=' . urlencode(drupal_get_path_alias(request_uri()));
              print '<a class="btn btn-small" href="/app/console">Manage Your Apps</a> ';
              print '<a class="btn btn-small" href="'. $logout_url .'">Sign Out</a>';
            } else {
       	      $login_url = variable_get('redhat_sso_login_url', $base_url . '/user');
              print '<a class="btn btn-small" href="'. $login_url .'">Sign in to participate</a>';
            }
            ?>
          </div>
        </div>
      </div>

      <div id="nav" class="section-nav lift-counter">
        <div class="navbar">
          <div class="container">
            <div class="brand">
              <a href="/">
                <div class="brand-image"></div>
                <div class="brand-text"><strong>Open</strong>Shift</div>
              </a>
            </div>
            <ul class="nav">
                <?php $i = 0; foreach( $primary_links as $key=>$link) {
                if ($i++ == 2) {
                  print '<li class="divider">&nbsp;</li>';
                }
                $link['options']['html'] = TRUE;
              ?>
                <li class="<?php print strpos($key,'active-trail') ? "active" : ""; ?>"><?php print l("<span>" . $link['title'] . "</span>", $link['href'], $link['options']); ?></li>
              <?php } ?>
            </ul>
          </div>
        </div>

        <?php print $messaging; ?>

      </div>
    </header>

    <div id="content" class="section-striped">
      <div class="container"><div class="row-content">
      <div class='row row-flush-right'>
        <?php if ($layout == 'left') :?>
      	<div class="column-navbar">      	
        	<a data-toggle="collapse" data-target=".nav-collapse" class="btn btn-navbar">
        	<span class="pull-left">Navigate</span>
        	<span class="pull-right">
        	<span class="icon-bar"></span>
        	<span class="icon-bar"></span>
        	<span class="icon-bar"></span>
        	</span>
        	</a>
        </div>
          <div class="column-nav lift-less grid-wrapper">
          <div class="nav-collapse collapse">
            <nav class="span3">
              <div class="gutter-right">
                <?php print $sidebar_left; ?>
              </div>
            </nav>
           </div>
          </div>
          <div class="column-content lift grid-wrapper">
            <div class="span9 span-flush-right">

        <?php elseif ($layout == 'both') :?>
          <div class="column-nav lift-less grid-wrapper">
            <nav class="span3">
              <div class="gutter-right">
                <?php print $sidebar_left; ?>
              </div>
            </nav>
          </div>
          <div class="column-content lift grid-wrapper">
            <div class="span6 span-flush-right">

        <?php elseif ($layout == 'right') :?>
          <div class="column-content lift grid-wrapper">
            <div class="span9 span-flush-right">

        <?php elseif ($layout == 'none') :?>
          <div class="column-content lift grid-wrapper">
            <div class="span12 span-flush-right">
        <?php endif; ?>

            <?php if ($heading) :?>
              <h1 class="ribbon">
                <div class="ribbon-content"><?php print $heading; ?></div>
                <div class="ribbon-left"></div>
              </h1>
            <?php endif; ?>

            <section class='default' id='about'>
              <?php if ($show_messages && $messages): print $messages; endif; ?>
            <?php print $breadcrumb; ?>
            <?php if ($tabs) :?>
            <div id="tabs"><?php print $tabs; ?></div>
            <?php endif; ?>
            <?php if ($forum['new-topic'] == TRUE) :?>
            <div id="forum-header" class="forum-new-topic">
              <div class="forum-header-left">
                <h2>Post a New Thread</h2>
              </div>
            </div>
            <?php endif; ?>
            <?php print $content_prefix; ?>
            <?php print $content; ?>

            </section>
            <?php print $content_suffix; ?>
         </div>

        <?php if ($layout == 'both' || $layout == 'right') :?>
          <div class="column-nav lift-less grid-wrapper">
            <div class="span3">
              <div class="gutter-right">
                <?php print $sidebar_right; ?>
              </div>
            </div>
          </div>
        <?php endif; ?>

          </div>
        </div>
      </div>
      </div></div>
    </div>
    <footer>
      <div id="footer-nav">
        <div class="container">
          <div class="row">
            <nav class="span3">
              <header>
                <h3><a href="/community/developers">Developers</a></h3>
              </header>
              <ul class="unstyled">
                <li><a href="/app/getting_started">Get Started</a></li>
                <li><a href="http://docs.redhat.com/docs/en-US/OpenShift/2.0/html/User_Guide/index.html">User Guide</a></li>
                <li><a href="/community/faq">FAQ</a></li>
                <li><a href="/pricing">Pricing</a></li>
              </ul>
            </nav>
            <nav class="span3">
              <header>
                <h3><a href="/community">Community</a></h3>
              </header>
              <ul class="unstyled">
                <li><a href="/community/blogs">Blog</a></li>
                <li><a href="/community/forums/">Forum</a></li>
                <li><a href="http://webchat.freenode.net/?randomnick=1&amp;channels=openshift&amp;uio=d4">IRC Channel</a></li>
                <li><a href="mailto:openshift@redhat.com">Feedback</a></li>
              </ul>
            </nav>
            <nav class="span3">
              <header>
                <h3><a href="/community/get-involved">Get Involved</a></h3>
              </header>
              <ul class="unstyled">
                <li><a href="/community/open-source">Open Source</a></li>
                <li><a href="/app/opensource/download">Get the Bits</a></li>
                <li><a href="/community/developers/get-involved">Make it Better</a></li>
                <li><a href="https://github.com/openshift">OpenShift on GitHub</a></li>
              </ul>
            </nav>
            <nav class="span3">
              <header>
                <h3><a href="/app/legal">Legal</a></h3>
              </header>
              <ul class="unstyled">
                <li><a href="/app/legal/services_agreement">Terms of Service</a></li>
                <li><a href="/app/legal/openshift_privacy">Privacy Policy</a></li>
                <li><a href="https://access.redhat.com/security/team/contact/">Security</a></li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
      <section id="copyright">
        <div class="container">
          <a href="https://www.redhat.com/">
            <img src="/app/images/redhat.png" alt="Red Hat">
          </a>
          <div class="pull-right">Copyright &copy; 2012 Red Hat, Inc.</div>
        </div>
      </section>
    </footer>
    <script type="text/javascript" src="/app/javascripts/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="/app/javascripts/bootstrap-collapse.js"></script>
    <script type="text/javascript" src="/app/javascripts/bootstrap-dropdown.js"></script>
    <!-- SiteCatalyst code version: H.23.3.
    Copyright 1996-2011 Adobe, Inc. All Rights Reserved
    More info available at http://www.omniture.com -->
    <div id="oTags">
    <script type="text/javascript" src="/app/javascripts/tracking.js"></script>
    <script type="text/javascript" src="/app/javascripts/omniture/s_code.js"></script>
    <script language="JavaScript" type="text/javascript"><!--
    /* You may give each page an identifying name, server, and channel on
    the next lines. */
    s.pageName="<?php if($node): echo $node->type . ' | ' . $node->name ?> |<?php endif; ?> openshift | community | <?php print $head_title; ?>"
    s.server=""
    s.channel="<?php if($product): ?>OpenShift | Product | <?php print $product; ?><?php endif; ?>"
    s.heir1=""
    s.pageType=""
    s.prop1=""
    s.prop2=""
    s.prop3=""
    s.prop4=""
    s.prop5=""
    /* Conversion Variables */
    s.campaign=""
    s.state=""
    s.zip=""
    s.events=""
    s.products=""
    s.purchaseID=""
    s.eVar1=""
    s.eVar2=""
    s.eVar3=""
    s.eVar4=""
    s.eVar5=""
    s.eVar51="<?php if($product): ?><?php print $product; ?><?php endif; ?>"
    s.eVar27=""
    s.eVar28=""
    s.eVar29=""
    /************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
    var s_code=s.t();if(s_code)document.write(s_code)//--></script>
    <script language="JavaScript" type="text/javascript"><!--
    if(navigator.appVersion.indexOf('MSIE')>=0)document.write(unescape('%3C')+'\!-'+'-')
    //--></script><noscript><img src="http://redhat.122.2o7.net/b/ss/redhatopenshift/1/H.23.3--NS/0"
    height="1" width="1" border="0" alt="" /></noscript><!--/DO NOT REMOVE/-->
    <!-- End SiteCatalyst code version: H.23.3. -->
    </div>
    <div style="display:none;"> <?php # FIXME remove after sprint 10 ?>
    <script src="/app/status/status.js?id=outage" type="text/javascript"></script>
    </div>
  </body>
<?php print $closure; ?>
</script>
</html>
