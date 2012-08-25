<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function blogs_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
}

/**
 * Implementation of hook_imagecache_default_presets().
 */
function blogs_imagecache_default_presets() {
  $items = array(
    'blog_author_image_30x30' => array(
      'presetname' => 'blog_author_image_30x30',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_resize',
          'data' => array(
            'width' => '30',
            'height' => '30',
          ),
        ),
      ),
    ),
    'blog_author_image_80x80' => array(
      'presetname' => 'blog_author_image_80x80',
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
    'blog_insert_image' => array(
      'presetname' => 'blog_insert_image',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale',
          'data' => array(
            'width' => '600',
            'height' => '400',
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
function blogs_node_info() {
  $items = array(
    'author' => array(
      'name' => t('Author'),
      'module' => 'features',
      'description' => t('Holds author information for members who will be publishing to the blog.  This content type does not hold information for regular community users.'),
      'has_title' => '1',
      'title_label' => t('Author Name'),
      'has_body' => '1',
      'body_label' => t('Short Bio'),
      'min_word_count' => '0',
      'help' => '',
    ),
    'blog' => array(
      'name' => t('Blog'),
      'module' => 'features',
      'description' => '',
      'has_title' => '1',
      'title_label' => t('Title'),
      'has_body' => '1',
      'body_label' => t('Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
    'newsletter' => array(
      'name' => t('Newsletter'),
      'module' => 'features',
      'description' => '',
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
function blogs_views_api() {
  return array(
    'api' => '2',
  );
}
