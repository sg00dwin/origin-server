<?php if (!$status) { ?><div class="node-unpublished"><?php } ?>

  <?php if ($submitted): ?>
    <span class="submitted"><?php print $submitted; ?></span>
  <?php endif; ?>

  <?php if ($node->taxonomy && !empty($node->taxonomy)): ?>
    <div class="terms terms-page"><ul class="inline"><?php foreach($node->taxonomy as $term) { ?>
      <li><a class="label" href="/tags/<?php print $term->name; ?>"><?php print $term->name; ?></a></li>
    <?php }?></ul></div>
  <?php endif;?>

  <?php print $content ?>

  <!-- <?php if ($taxonomy): ?>
    <div class="terms-page">Tags: <?php print $terms ?></div>
  <?php endif;?>

  <?php if ($links): ?>
    <div class="links"><?php print $links; ?></div>
  <?php endif; ?> -->

<?php if (!$status) { ?></div><?php } ?>
