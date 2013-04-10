<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function application_quickstarts_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
}

/**
 * Implementation of hook_imagecache_default_presets().
 */
function application_quickstarts_imagecache_default_presets() {
  $items = array(
    'generic_icon_150_50' => array(
      'presetname' => 'generic_icon_150_50',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale',
          'data' => array(
            'width' => '150',
            'height' => '75',
            'upscale' => 0,
          ),
        ),
      ),
    ),
    'generic_icon_256_256' => array(
      'presetname' => 'generic_icon_256_256',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale',
          'data' => array(
            'width' => '256',
            'height' => '256',
            'upscale' => 0,
          ),
        ),
      ),
    ),
  );
  return $items;
}

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
