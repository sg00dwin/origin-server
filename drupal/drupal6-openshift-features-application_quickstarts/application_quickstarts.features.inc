<?php

/**
 * Implementation of hook_node_info().
 */
function application_quickstarts_node_info() {
  $items = array(
    'quickstart' => array(
      'name' => t('Quickstart'),
      'module' => 'features',
      'description' => t('A type of application that can be deployed via OpenShift, including the cartridges and git URL the application might start with.'),
      'has_title' => '1',
      'title_label' => t('Title'),
      'has_body' => '1',
      'body_label' => t('Description'),
      'min_word_count' => '0',
      'help' => '',
    ),
  );
  return $items;
}

/**
 * Implementation of hook_views_api().
 */
function application_quickstarts_views_api() {
  return array(
    'api' => '2',
  );
}
