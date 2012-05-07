<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function community_wiki_user_default_permissions() {
  $permissions = array();

  // Exported permission: attach images
  $permissions['attach images'] = array(
    'name' => 'attach images',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: create images
  $permissions['create images'] = array(
    'name' => 'create images',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: create wiki_page content
  $permissions['create wiki_page content'] = array(
    'name' => 'create wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: delete any images
  $permissions['delete any images'] = array(
    'name' => 'delete any images',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: delete any wiki_page content
  $permissions['delete any wiki_page content'] = array(
    'name' => 'delete any wiki_page content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: delete own images
  $permissions['delete own images'] = array(
    'name' => 'delete own images',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: delete own wiki_page content
  $permissions['delete own wiki_page content'] = array(
    'name' => 'delete own wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit any images
  $permissions['edit any images'] = array(
    'name' => 'edit any images',
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

  // Exported permission: edit own images
  $permissions['edit own images'] = array(
    'name' => 'edit own images',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit own wiki_page content
  $permissions['edit own wiki_page content'] = array(
    'name' => 'edit own wiki_page content',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: view original images
  $permissions['view original images'] = array(
    'name' => 'view original images',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  return $permissions;
}
