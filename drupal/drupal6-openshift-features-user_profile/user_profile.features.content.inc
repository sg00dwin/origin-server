<?php

/**
 * Implementation of hook_content_default_fields().
 */
function user_profile_content_default_fields() {
  $fields = array();

  // Exported field: field_file
  $fields['file-field_file'] = array(
    'field_name' => 'field_file',
    'type_name' => 'file',
    'display_settings' => array(
      'label' => array(
        'format' => 'above',
        'exclude' => 0,
      ),
      'teaser' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '4' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '2' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '3' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      'token' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'filefield',
    'required' => '1',
    'multiple' => '0',
    'module' => 'filefield',
    'active' => '1',
    'list_field' => '0',
    'list_default' => 1,
    'description_field' => '0',
    'widget' => array(
      'file_extensions' => '',
      'file_path' => 'file_downloads',
      'progress_indicator' => 'bar',
      'max_filesize_per_file' => '50M',
      'max_filesize_per_node' => '50M',
      'insert' => 0,
      'insert_styles' => array(
        'auto' => 0,
        'link' => 0,
        'image' => 0,
        'imagecache_blog_author_image_30x30' => 0,
        'imagecache_blog_author_image_80x80' => 0,
        'imagecache_blog_insert_image' => 0,
        'imagecache_user_image_large_80x80' => 0,
        'imagecache_user_image_medium_40x40' => 0,
        'imagecache_user_image_small_20x20' => 0,
      ),
      'insert_default' => 'auto',
      'insert_class' => '',
      'insert_width' => '',
      'label' => 'File',
      'weight' => '31',
      'description' => 'A file that will be visible to people on OpenShift.',
      'type' => 'filefield_widget',
      'module' => 'filefield',
    ),
  );

  // Exported field: field_website
  $fields['partner-field_website'] = array(
    'field_name' => 'field_website',
    'type_name' => 'partner',
    'display_settings' => array(
      'weight' => '1',
      'parent' => 'group_quickstart_info',
      '2' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '3' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      'label' => array(
        'format' => 'inline',
      ),
      'teaser' => array(
        'format' => 'url',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'url',
        'exclude' => 0,
      ),
      'token' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '4' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'link',
    'required' => '0',
    'multiple' => '0',
    'module' => 'link',
    'active' => '1',
    'attributes' => array(
      'target' => 'default',
      'rel' => '',
      'class' => '',
      'title' => '',
    ),
    'display' => array(
      'url_cutoff' => '80',
    ),
    'url' => 0,
    'title' => 'none',
    'title_value' => '',
    'enable_tokens' => 0,
    'validate_url' => 0,
    'widget' => array(
      'default_value' => array(
        '0' => array(
          'url' => '',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Website',
      'weight' => '8',
      'description' => 'A website for this quickstart',
      'type' => 'link',
      'module' => 'link',
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('File');
  t('Website');

  return $fields;
}
