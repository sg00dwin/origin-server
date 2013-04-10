<div id="node-<?php print $node->nid; ?>" class="<?php print $node->type; ?> node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">

<?php //print theme('user_picture', $node); ?>
  <?php // Don't print title on page content, it'll be at the top of the page ?>
  <?php if ($submitted): ?>
    <span class="submitted"><?php print $submitted; ?></span>
  <?php endif; ?>

  <div class="content clear-block">
    <?php print $content ?>
  </div>

  <?php if ($taxonomy): ?>
    <div class="terms">Tags: <?php print $terms ?></div>
  <?php endif;?>

  <?php if ($links): ?>
    <div class="links"><?php print $links; ?></div>
  <?php endif; ?>

</div>
