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
      //print_r(end(menu_get_active_trail()));
      $css_host = variable_get('openshift_url', NULL);
      if ($css_host) {
        $css_host .= '/app';
    ?>
      <link type="image/png" rel="shortcut icon" href="<?php print $css_host; ?>/images/favicon-32.png">
      <link type="text/css" rel="stylesheet" href="<?php print $css_host; ?>/stylesheets/common.css"></link>
      <link type="text/css" rel="stylesheet" href="<?php print $css_host; ?>/stylesheets/site.css"></link>
<?php } else { 
        $css_host = $base_path . drupal_get_path('theme', 'openshift');
    ?>
      <link type="image/png" rel="shortcut icon" href="<?php print $css_host; ?>/images/favicon-32.png">
      <link type="text/css" rel="stylesheet" href="<?php print $css_host; ?>/css/site.css"></link>
    <?php } ?>
	  <?php print $styles; ?>
	  <?php print $scripts; ?>
    <meta content='' name='description'>
    <meta content='' name='author'>
    <meta content='width=device-width, initial-scale=1.0' name='viewport'>
    <meta name="csrf-param" content="authenticity_token"/>
    <meta name="csrf-token" content="+CyXrdA5MZFVwLks73ibMfRiwRE+ixICENvvHms1Exk="/>
    <meta name="viewport" content="width=1100" />
  </head>
  <body class='community'>
    <header>
      <div id="top" class="section-top">
        <div class="container">
          <div class="pull-left"><a href="http://makara.nurturehq.com/makara/newsletter_signup.html">Sign up for the newsletter</a></div>
          <div class="pull-right login">
            <?php
            global $user;

            if ( $user->uid ) { 
       	      $login_url = variable_get('redhat_sso_login_url', NULL);
              print '<a class="btn btn-small" href="'. base_path() .'logout">Sign out</a>';
            } else {
       	      $login_url = variable_get('redhat_sso_login_url', NULL);
              print '<a class="btn btn-small" href="'. $login_url .'">Sign in</a>';
            }
            ?>
          </div>
        </div>
      </div>

      <div id="nav" class="section-nav lift-counter">
        <div class="navbar">
          <div class="container">
            <div class="brand">
              <a href="https://openshift.redhat.com">
                <div class="brand-image"></div>
                <div class="brand-text"></div>
              </a>
            </div>
            <ul class="nav">
              <li><a href="https://openshift.redhat.com/app/platform"><span>Overview</span></a></li>
              <li><a href="https://openshift.redhat.com/app/express"><span>Express</span></a></li>
              <li class="divider">&nbsp;</li>
              <li><a href="https://openshift.redhat.com/app/flex"><span>Flex</span></a></li>
              <li class="active"><a href="https://www.redhat.com/openshift/community"><span>Community</span></a></li>
            </ul>
          </div>
        </div>

        <?php if ( ! $user->uid ) :?>
        <div class="messaging">
          <div class="container">
            <div class="primary headline">
              Join the
              <strong>OpenShift Community</strong>
            </div>
            <div class="secondary">This is the place to learn and engage with OpenShift users and developers. Sign in to participate</div>
          </div>
        </div>
        <?php endif; ?>

      </div>
    </header>

    <div id="content" class="section-striped">
      <div class="container"><div class="row-content">
      <div class='row row-flush-right'>
        <?php if ($column_right) :?>
          <div class="column-nav lift-less grid-wrapper">
            <nav class="span3">
              <div class="gutter-right">
                <?php print $column_right; ?>
              </div>
            </nav>
          </div>
        <?php endif; ?>
          <div class="column-content lift grid-wrapper">
            <div class="span<?php print $column_right ? '9' : '12' ?> span-flush-right">
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
            <?php print $content_suffix; ?>
            
            </section>
          </div>
        </div>
      </div>
      </div></div>
    </div>
    <footer>
      <div id="footer-nav">
        <div class="container">
          <div class="row">
            <div class="span3 link-column">
              <header>
                <h3>News</h3>
              </header>
              <ul class="unstyled">
                <li><a href="https://www.redhat.com/openshift/forums/news-and-announcements">Announcements</a></li>
                <li><a href="https://www.redhat.com/openshift/blogs">Blog</a></li>
                <li><a href="http://www.twitter.com/#!/openshift">Twitter</a></li>
              </ul>
            </div>
            <div class="span3 link-column">
              <header>
                <h3>Community</h3>
              </header>
              <ul class="unstyled">
                <li><a href="https://www.redhat.com/openshift/forums/">Forum</a></li>
                <li><a href="/app/partners">Partner Program</a></li>
                <li><a href="http://webchat.freenode.net/?randomnick=1&amp;channels=openshift&amp;uio=d4">IRC Channel</a></li>
                <li><a href="mailto:openshift@redhat.com">Feedback</a></li>
              </ul>
            </div>
            <div class="span3 link-column">
              <header>
                <h3>Legal</h3>
              </header>
              <ul class="unstyled">
                <li><a href="/app/legal">Legal</a></li>
                <li><a href="/app/legal/openshift_privacy">Privacy Policy</a></li>
                <li><a href="https://access.redhat.com/security/team/contact/">Security</a></li>
              </ul>
            </div>
            <div class="span3 link-column">
              <header>
                <h3>Help</h3>
              </header>
              <ul class="unstyled">
                <li><a href="http://www.redhat.com/openshift/faq">FAQ</a></li>
                <li><a href="mailto:openshift@redhat.com">Contact</a></li>
              </ul>
            </div>
          </div>
          </div>
        </div>     
        <section id='copyright'>
        <div class='container'>
        <img src="<?php print $css_host; ?>/images/redhat.png" alt="Red Hat">
          <div class="pull-right">Copyright &copy; 2012 Red Hat, Inc.</div>
        </div>
      </section>
    </footer>
    <!-- SiteCatalyst code version: H.23.3.
    Copyright 1996-2011 Adobe, Inc. All Rights Reserved
    More info available at http://www.omniture.com -->
    <div id="oTags">
    <script type="text/javascript" src="https://openshift.redhat.com/app/javascripts/omniture/s_code.js"></script>
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
  </body>
<?php print $closure; ?>
</script>
</html>
