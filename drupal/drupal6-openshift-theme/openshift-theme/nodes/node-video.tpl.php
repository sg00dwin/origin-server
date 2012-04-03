<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> node-blog">

<h2><?php print $title; ?></h2>


  <div class="content clear-block">
    <?php if (geoip_country_code() == 'CN'): ?>  
      <?php print $content ?>
      <?php print $field_video_youku_rendered; ?>
    <?php else: ?>
      <?php print $content ?>
      <?php print $field_video_third_party_rendered; ?> 
    <?php endif; ?>
  </div>

  <div class="clear-block">
    <div class="meta">
    <?php if ($taxonomy): ?>
      <div class="terms"><?php print $terms ?></div>
    <?php endif;?>
    </div>

    <?php if ($links): ?>
      <div class="links"><?php print $links; ?></div>
    <?php endif; ?>
  </div>

</div>
