<?php

/**
 * Implementation of hook_node_info().
 */
function forums_node_info() {
  $items = array(
    'discussion' => array(
      'name' => t('Forum Thread'),
      'module' => 'features',
      'description' => t('A conversation about a particular topic in the forum.'),
      'has_title' => '1',
      'title_label' => t('Thread Title'),
      'has_body' => '1',
      'body_label' => t('Message Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
    'group' => array(
      'name' => t('Forum'),
      'module' => 'features',
      'description' => t('A discussion forum containing threads and comments.'),
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
