<?php

/**
 * Implementation of hook_node_info().
 */
function redhat_ideas_node_info() {
  $items = array(
    'idea' => array(
      'name' => t('Idea'),
      'module' => 'features',
      'description' => t('Used to crowd source OpenShift features. '),
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
function redhat_ideas_views_api() {
  return array(
    'api' => '2',
  );
}
