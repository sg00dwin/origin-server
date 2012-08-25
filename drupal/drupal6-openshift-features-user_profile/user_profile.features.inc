<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function user_profile_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
}

/**
 * Implementation of hook_imagecache_default_presets().
 */
function user_profile_imagecache_default_presets() {
  $items = array(
    'user_image_large_80x80' => array(
      'presetname' => 'user_image_large_80x80',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale_and_crop',
          'data' => array(
            'width' => '80',
            'height' => '80',
          ),
        ),
      ),
    ),
    'user_image_medium_40x40' => array(
      'presetname' => 'user_image_medium_40x40',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale_and_crop',
          'data' => array(
            'width' => '40',
            'height' => '40',
          ),
        ),
      ),
    ),
    'user_image_small_20x20' => array(
      'presetname' => 'user_image_small_20x20',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale_and_crop',
          'data' => array(
            'width' => '20',
            'height' => '20',
          ),
        ),
      ),
    ),
  );
  return $items;
}

/**
 * Implementation of hook_views_api().
 */
function user_profile_views_api() {
  return array(
    'api' => '2',
  );
}
