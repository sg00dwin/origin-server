<div id="node-<?php print $node->nid; ?>" class="<?php print $node->type; ?> node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">

<?php //print theme('user_picture', $node); ?>
  <?php // Don't print title on page content, it'll be at the top of the page ?>
  <?php if ($submitted): ?>
    <span class="submitted"><?php print $submitted; ?></span>
  <?php endif; ?>

  <div class="content clear-block">
    <?php print $content ?>
  </div>

  <div class="clear-block">
    <div class="meta">
    <?php if ($taxonomy): ?>
      <div class="terms"><?php print $terms ?></div>
    <?php endif;?>
    </div>

    <?php if ($links): ?>
      <div class="btn-toolbar"><?php print $links; ?></div>
    <?php endif; ?>
  </div>

</div>
