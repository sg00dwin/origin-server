<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> node-blog">

  <div class="content clearfix">
    <?php if (geoip_country_code() == 'CN'): ?>  
      <?php print $field_video_youku_rendered; ?>
      <?php print $content ?>
    <?php else: ?>
      <?php print $field_video_third_party_rendered; ?> 
      <?php print $content ?>
    <?php endif; ?>
  </div>

  <?php if ($taxonomy): ?>
    <div class="terms">Tags: <?php print $terms ?></div>
  <?php endif;?>

  <?php if ($links): ?>
    <div class="links"><?php print $links; ?></div>
  <?php endif; ?>

  <?php print openshift_social_sharing($node_url, $title); ?>    

</div>
