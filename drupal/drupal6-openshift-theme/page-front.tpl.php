<?php include 'page_header.inc' ?>

    <header>
      <?php include 'page-front_top.inc' ?>
      <?php include 'page_nav.inc' ?>
    </header>

<div id="learn" class="section-striped lift-counter">
<div class="container container-inset">
<div class="row">
  <a class="action-call span12" href="<?php print $openshift_server_url; ?>/app/account/new"><div>Get started in the cloud</div><div class="highlight">SIGN UP - IT'S FREE</div><div class="highlight-arrow">&gt;</div></a>
  <div class="span6">
    <ul class="learn unstyled">
    <li class="scale">
    <a class="link-tile" href="/paas#scale"><img src="<?php print $openshift_server_url; ?>/app/assets/scale.png">
    <h4>Java, Ruby, Node.js, Python, PHP, or Perl</h4>
    <p>Code in your favorite language, framework, and middleware.  Grow your applications easily with resource scaling.</p>
    </a></li>
    <li class="time">
    <a class="link-tile" href="/enterprise-paas"><img src="<?php print $openshift_server_url; ?>/app/assets/time.png">
    <h4>Private and Public Platform as a Service</h4>
    <p>
    OpenShift Enterprise by Red Hat brings the
    ease-of-use, elasticity, and power of the
    OpenShift PaaS to the enterprise.  Deployable
    on-premise in your datacenter or in your
    Private Cloud.  Now there is no excuse.
    </p>
    </a></li>
    <li class="locked">
    <a class="link-tile" href="/paas#open"><img src="<?php print $openshift_server_url; ?>/app/assets/lock.png">
    <h4>No Lock-In</h4>
    <p>Built on open technologies so you can take it with you.</p>
    </a></li>
    </ul>
    <p class="gutter"><a class="action-more" href="/paas">Learn about OpenShift</a></p>
  </div>
  <div class="span6">
    <?php print views_embed_view('nodes_by_category', 'block_4'); ?>
  </div>
</div>
</div>
</div>

<div id="buzz" class="section-base">
<div class="container">
<div class="row row-buzz lift">
<div class="span12">
<div class="column-buzz">
<h2>
Check the
<strong>Buzz</strong>
</h2>
<hr>
<div class="row-fluid">
  <div id="buzz-tweets" class="span5"><?php print _redhat_frontpage_load_tweets(); ?></div>
  <div class="span1">&nbsp;</div>
  <div id="buzz-retweets" class="span6"><?php print _redhat_frontpage_load_retweets(); ?></div>
</div>
<div class="row-fluid buzz-actions">
<div class="span6">
<a class="link-with-action" href="/"><strong>Join</strong>
our community
</a></div>
<div class="span6">
<div class="align-right">
<a class="link-with-action" href="http://www.twitter.com/#!/openshift"><strong>Follow</strong>
OpenShift
</a></div>
<div class="align-right">
<a class="link-with-action" href="http://twitter.com/#!/search/%23OpenShift"><strong>More</strong>
#OpenShift buzz
</a></div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>

<?php include 'page_footer.inc' ?>
