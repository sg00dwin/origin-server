<?php drupal_set_title(strip_email($account->name)); ?>
<div id="profile">
  <h2><?php $account->uid === $user->uid ? print 'Your Profile' : print 'User Profile' ?></h2>
  <?php if ($account->uid === $user->uid): ?>
  <div class="profile-edit-link"><a href="<?php print base_path() .'user/'. $user->uid; ?>/edit">[Edit]</a></div>
  <?php endif; ?> 
  <div class="profile-top">
    <?php print $profile['user_picture']; ?>
    <div class="profile-top-details">
      <div class="profile-display-name"><a href="<?php print base_path() . 'user/'. $account->uid; ?>"><?php !empty($account->profile_display_name) ? print check_plain($account->profile_display_name) : print strip_email($account->name); ?></a></div>
      <span class="profile-data-content">
        <?php $full_name = $account->profile_first_name.' '.$account->profile_last_name; ?>
        <?php $clean_name = trim(strip_tags($full_name)); ?>
        <?php $clean_profession = trim(strip_tags($account->profile_profession)); ?>
        <?php print check_plain($full_name); if (!empty($clean_name) && !empty($clean_profession)) { print ', '. check_plain($account->profile_profession); } ?>
      </span>
      <?php if (isset($account->badges) && is_array($account->badges)): ?>
      <?php foreach ($account->badges as $badge): ?>
        <div class="profile-badge"><img src="<?php print base_path() . $badge->image; ?>" /></div>
      <?php endforeach; ?>
      <?php endif; ?>
      <?php $points_array = explode('-', $account->content['userpoints']['points']['#value']); ?>
      <div class="profile-points"><?php print $points_array[0] .' '. $account->content['userpoints']['points']['#title']; ?> <?php in_array('administrator', array_values($user->roles)) ? print ' - '.  $points_array[1] : FALSE; ?></div>
    </div>
    <div class="profile-subscription-links">
    <?php if ($user->uid && $account->uid): ?>
      <?php if ($sid > 0): ?>
        <a href="<?php print base_path() ?>notifications/unsubscribe/sid/<?php print $sid; ?>?destination=user%2F<?php print $account->uid; ?>">Unsubscribe from <?php print strip_email($account->name); ?></a>
      <?php else: ?>
        <a href="<?php print base_path() ?>notifications/subscribe/<?php print $user->uid ?>/author/author/<?php print $account->uid; ?>?destination=user%2F<?php print $account->uid; ?>">Subscribe to <?php print strip_email($account->name); ?></a>
      <?php endif; ?>
    <?php endif; ?>
    </div>
  </div>
  <div style="clear: left; padding-top: 20px;">
  <?php
  unset($profile['user_badges']);
  unset($profile['summary']);
  unset($profile['userpoints']);
  ?>
  <?php print $profile['My Profile']; ?>
  </div>
  <?php print views_embed_view('threads_by_popularity', 'block_5', $account->uid); ?>
</div>
