<?php
//echo '<pre>';
//print_r($node->uid);
//$user->uid;
//echo '</pre>';
$do = og_comment_perms_do();
?>
<div id="node-<?php print $node->nid; ?>" class="event <?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?>">

  <h3><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print $title ?></a></h3>

  <div class="content">
    <?php print $content ?>
  </div>
  <?php if ($do->perm == 'post'): ?>
  
  <br />
  <?php endif; ?>
  
  
</div>
