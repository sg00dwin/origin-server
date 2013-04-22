<?php

/**
 * Implementation of hook_user_default_roles().
 */
function user_profile_user_default_roles() {
  $roles = array();

  // Exported role: administrator
  $roles['administrator'] = array(
    'name' => 'administrator',
  );

  // Exported role: anonymous user
  $roles['anonymous user'] = array(
    'name' => 'anonymous user',
  );

  // Exported role: authenticated user
  $roles['authenticated user'] = array(
    'name' => 'authenticated user',
  );

  // Exported role: blogger
  $roles['blogger'] = array(
    'name' => 'blogger',
  );

  // Exported role: content author
  $roles['content author'] = array(
    'name' => 'content author',
  );

  // Exported role: doc content owner
  $roles['doc content owner'] = array(
    'name' => 'doc content owner',
  );

  // Exported role: moderator
  $roles['moderator'] = array(
    'name' => 'moderator',
  );

  // Exported role: page author
  $roles['page author'] = array(
    'name' => 'page author',
  );

  return $roles;
}
