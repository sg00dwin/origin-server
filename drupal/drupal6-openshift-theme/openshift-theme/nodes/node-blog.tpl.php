<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> node-blog">

<h2><?php print $title; ?></h2>
<p><?php print readabledate($node->created); ?></p>
<?php 
$author_nid = $field_author[0]['nid'];
print views_embed_view('author_profile_box', 'block_1', $author_nid);
?>

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
      <div class="links"><?php print $links; ?></div>
    <?php endif; ?>
  </div>

</div>
