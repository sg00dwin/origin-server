<?php
$do = og_comment_perms_do();
?>
<div class="comment<?php print ($comment->new) ? ' comment-new' : ''; print ' '. $status; print ' '. $zebra; ?>">


    <div class="comment-author clearfix">
      <?php print views_embed_view('user_profile_box', 'block_2', $comment->uid); ?>
      <?php if ($submitted): ?>
        <div class="submitted right"><?php print 'Posted ' . format_date($comment->timestamp, $type='custom', $format = 'F j, Y \a\t g:i A'); ?></div>
      <?php endif; ?> 
    </div>
    
    <div class="comment-content">
      <?php if ($comment->new) : ?>
        <span class="label new pull-right"><?php print drupal_ucfirst($new) ?></span>
      <?php endif; ?>

      <?php //print theme('user_picture', $comment); ?>


      <?php /* Always hide the title 
        if (!empty($comment->subject) && strpos($content, check_plain($comment->subject)) === false) { ?>
      <h3><?php print $title . $uid; ?></h3>
        <?php } */ ?>

      <div class="content">
        <?php print $content ?>
        <?php if ($signature): ?>
        <div class="clear-block">
          <div>&nbsp;</div>
          <?php print $signature ?>
        </div>
        <?php endif; ?>
      </div>
      
      <?php if ($do->perm == 'post'): ?>
        <?php if ($links): ?>
          <?php print $links ?>
        <?php endif; ?>
      <?php endif; ?>
		</div>
  
</div>
<div class="b-edge"></div>
