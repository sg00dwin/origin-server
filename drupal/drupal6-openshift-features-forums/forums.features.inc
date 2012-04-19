<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function forums_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
}

/**
 * Implementation of hook_node_info().
 */
function forums_node_info() {
  $items = array(
    'discussion' => array(
      'name' => t('Discussion'),
      'module' => 'features',
      'description' => '',
      'has_title' => '1',
      'title_label' => t('Thread Title'),
      'has_body' => '1',
      'body_label' => t('Message Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
    'group' => array(
      'name' => t('Group'),
      'module' => 'features',
      'description' => t('Use this to create a new group.'),
      'has_title' => '1',
      'title_label' => t('Title'),
      'has_body' => '1',
      'body_label' => t('Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
  );
  return $items;
}

/**
 * Implementation of hook_views_api().
 */
function forums_views_api() {
  return array(
    'api' => '2',
  );
}
