<div id="node-<?php print $node->nid; ?>" class="<?php print $node->type; ?> node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">

  <?php if ($title != $heading): ?>
  <h2><?php print $title ?></h2>
  <?php endif; ?>

  <div class="content clear-block">
    <?php print $content ?>
  </div>

  <?php if ($submitted): ?>
    <span class="submitted"><?php print $submitted; ?></span>
  <?php endif; ?>

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
