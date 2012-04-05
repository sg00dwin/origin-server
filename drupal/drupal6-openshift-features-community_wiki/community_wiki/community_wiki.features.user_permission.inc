<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function community_wiki_user_default_permissions() {
  $permissions = array();

  // Exported permission: create wiki_page content
  $permissions['create wiki_page content'] = array(
    'name' => 'create wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: delete any wiki_page content
  $permissions['delete any wiki_page content'] = array(
    'name' => 'delete any wiki_page content',
    'roles' => array(),
  );

  // Exported permission: delete own wiki_page content
  $permissions['delete own wiki_page content'] = array(
    'name' => 'delete own wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit any wiki_page content
  $permissions['edit any wiki_page content'] = array(
    'name' => 'edit any wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit own wiki_page content
  $permissions['edit own wiki_page content'] = array(
    'name' => 'edit own wiki_page content',
    'roles' => array(),
  );

  return $permissions;
}
