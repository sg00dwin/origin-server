<?php
$do = og_comment_perms_do();
?>
<div class="comment<?php print ($comment->new) ? ' comment-new' : ''; print ' '. $status; print ' '. $zebra; ?>">


    <div class="comment-author clearfix">
      <?php print views_embed_view('user_profile_box', 'block_2', $comment->uid); ?>
      
    </div>
    
    <div class="comment-content">
      <?php if ($comment->new) : ?>
        <span class="new"><?php print drupal_ucfirst($new) ?></span>
      <?php endif; ?>

      <?php //print theme('user_picture', $comment); ?>

      <h3><?php print $title . $uid; ?></h3>

      <div class="content">
        <?php print $content ?>
        <?php if ($signature): ?>
        <div class="clear-block">
          <div>&nbsp;</div>
          <?php print $signature ?>
        </div>
        <?php endif; ?>
      </div>
      <?php if ($submitted): ?>
        <span class="submitted"><?php print 'Posted ' . format_date($comment->timestamp, $type='custom', $format = 'F j, Y \a\t g:i A'); ?></span>
      <?php endif; ?>
      <?php if ($do->perm == 'post'): ?>
        <?php if ($links): ?>
          <?php print $links ?>
        <?php endif; ?>
      <?php endif; ?>
		</div>
  
</div>
