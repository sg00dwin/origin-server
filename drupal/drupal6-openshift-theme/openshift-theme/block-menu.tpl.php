<?php
?>
<div id="block-<?php print $block->module .'-'. $block->delta; ?>" class="block block-<?php print $block->module ?>">
<?php if ($block->subject): ?>
  <div class="nav-location headline"><?php print $block->subject ?></div>
<?php endif;?>

  <div class="content">
    <?php print $block->content ?>
  </div>
</div>
