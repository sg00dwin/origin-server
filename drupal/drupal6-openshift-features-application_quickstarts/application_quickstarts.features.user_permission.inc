<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function application_quickstarts_user_default_permissions() {
  $permissions = array();

  // Exported permission: create quickstart content
  $permissions['create quickstart content'] = array(
    'name' => 'create quickstart content',
    'roles' => array(),
  );

  // Exported permission: delete any quickstart content
  $permissions['delete any quickstart content'] = array(
    'name' => 'delete any quickstart content',
    'roles' => array(),
  );

  // Exported permission: delete own quickstart content
  $permissions['delete own quickstart content'] = array(
    'name' => 'delete own quickstart content',
    'roles' => array(),
  );

  // Exported permission: edit any quickstart content
  $permissions['edit any quickstart content'] = array(
    'name' => 'edit any quickstart content',
    'roles' => array(),
  );

  // Exported permission: edit field_cartridges_list
  $permissions['edit field_cartridges_list'] = array(
    'name' => 'edit field_cartridges_list',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit field_code_language
  $permissions['edit field_code_language'] = array(
    'name' => 'edit field_code_language',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit field_git_repository_url
  $permissions['edit field_git_repository_url'] = array(
    'name' => 'edit field_git_repository_url',
    'roles' => array(
      '0' => 'authenticated user',
    ),
  );

  // Exported permission: edit field_quickstart_admin_tags
  $permissions['edit field_quickstart_admin_tags'] = array(
    'name' => 'edit field_quickstart_admin_tags',
    'roles' => array(),
  );

  // Exported permission: edit field_quickstart_icon
  $permissions['edit field_quickstart_icon'] = array(
    'name' => 'edit field_quickstart_icon',
    'roles' => array(),
  );

  // Exported permission: edit field_quickstart_priority
  $permissions['edit field_quickstart_priority'] = array(
    'name' => 'edit field_quickstart_priority',
    'roles' => array(),
  );

  // Exported permission: edit field_summary
  $permissions['edit field_summary'] = array(
    'name' => 'edit field_summary',
    'roles' => array(),
  );

  // Exported permission: edit field_website
  $permissions['edit field_website'] = array(
    'name' => 'edit field_website',
    'roles' => array(),
  );

  // Exported permission: edit own quickstart content
  $permissions['edit own quickstart content'] = array(
    'name' => 'edit own quickstart content',
    'roles' => array(),
  );

  // Exported permission: view field_cartridges_list
  $permissions['view field_cartridges_list'] = array(
    'name' => 'view field_cartridges_list',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_code_language
  $permissions['view field_code_language'] = array(
    'name' => 'view field_code_language',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_git_repository_url
  $permissions['view field_git_repository_url'] = array(
    'name' => 'view field_git_repository_url',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_quickstart_admin_tags
  $permissions['view field_quickstart_admin_tags'] = array(
    'name' => 'view field_quickstart_admin_tags',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_quickstart_icon
  $permissions['view field_quickstart_icon'] = array(
    'name' => 'view field_quickstart_icon',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_quickstart_priority
  $permissions['view field_quickstart_priority'] = array(
    'name' => 'view field_quickstart_priority',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  // Exported permission: view field_summary
  $permissions['view field_summary'] = array(
    'name' => 'view field_summary',
    'roles' => array(),
  );

  // Exported permission: view field_website
  $permissions['view field_website'] = array(
    'name' => 'view field_website',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
    ),
  );

  return $permissions;
}
