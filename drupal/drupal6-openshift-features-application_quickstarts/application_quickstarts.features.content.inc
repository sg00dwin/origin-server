<?php

/**
 * Implementation of hook_content_default_fields().
 */
function application_quickstarts_content_default_fields() {
  $fields = array();

  // Exported field: field_cartridges_list
  $fields['quickstart-field_cartridges_list'] = array(
    'field_name' => 'field_cartridges_list',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => '-2',
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
        'format' => 'default',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'default',
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
    'type' => 'text',
    'required' => '1',
    'multiple' => '0',
    'module' => 'text',
    'active' => '1',
    'text_processing' => '0',
    'max_length' => '',
    'allowed_values' => '',
    'allowed_values_php' => '',
    'widget' => array(
      'rows' => 5,
      'size' => '4096',
      'default_value' => array(
        '0' => array(
          'value' => '',
          '_error_element' => 'default_value_widget][field_cartridges_list][0][value',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Cartridges',
      'weight' => '-2',
      'description' => '<p>All Quickstarts must require one or more cartridges.  When specifying a list of cartridges, you can do so using</p>
<ul>
<li>A comma delimited list of cartridge names: <code>php-5.3, mysql-5.1</code></li>
<li>A JSON array containing the parameters to pass to the cartridge: 
<pre>
[{"name": "php-5.3"}, {"name": "mysql-5.1"}]
</pre>
</li>
</ul>',
      'type' => 'text_textfield',
      'module' => 'text',
    ),
  );

  // Exported field: field_code_language
  $fields['quickstart-field_code_language'] = array(
    'field_name' => 'field_code_language',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => 0,
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
        'format' => 'default',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'default',
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
    'type' => 'text',
    'required' => '1',
    'multiple' => '0',
    'module' => 'text',
    'active' => '1',
    'text_processing' => '0',
    'max_length' => '',
    'allowed_values' => 'java|Java
php|PHP
ruby|Ruby
python|Python
javascript|JavaScript
other|Other',
    'allowed_values_php' => '',
    'widget' => array(
      'default_value' => array(
        '0' => array(
          'value' => 'other',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Language',
      'weight' => 0,
      'description' => '',
      'type' => 'optionwidgets_select',
      'module' => 'optionwidgets',
    ),
  );

  // Exported field: field_git_repository_url
  $fields['quickstart-field_git_repository_url'] = array(
    'field_name' => 'field_git_repository_url',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => '-1',
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
      'token' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'text',
    'required' => '0',
    'multiple' => '0',
    'module' => 'text',
    'active' => '1',
    'text_processing' => '0',
    'max_length' => '2048',
    'allowed_values' => '',
    'allowed_values_php' => '',
    'widget' => array(
      'rows' => 5,
      'size' => '80',
      'default_value' => NULL,
      'default_value_php' => NULL,
      'label' => 'Git Repository URL',
      'weight' => '-1',
      'description' => 'An optional URL to a Git repository that will be cloned into this quickstart on creation.  The created application will have the base content here.',
      'type' => 'text_textfield',
      'module' => 'text',
    ),
  );

  // Exported field: field_quickstart_admin_tags
  $fields['quickstart-field_quickstart_admin_tags'] = array(
    'field_name' => 'field_quickstart_admin_tags',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => '32',
      'parent' => 'group_quickstart_admin',
      '2' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '3' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'label' => array(
        'format' => 'hidden',
      ),
      'teaser' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'full' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'token' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      '4' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
    ),
    'widget_active' => '1',
    'type' => 'text',
    'required' => '0',
    'multiple' => '0',
    'module' => 'text',
    'active' => '1',
    'text_processing' => '0',
    'max_length' => '',
    'allowed_values' => '',
    'allowed_values_php' => '',
    'widget' => array(
      'rows' => 5,
      'size' => '60',
      'default_value' => array(
        '0' => array(
          'value' => '',
          '_error_element' => 'default_value_widget][field_quickstart_admin_tags][0][value',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Admin Tags',
      'weight' => '32',
      'description' => 'Provide administrative protected tags to be used',
      'type' => 'text_textfield',
      'module' => 'text',
    ),
  );

  // Exported field: field_quickstart_icon
  $fields['quickstart-field_quickstart_icon'] = array(
    'field_name' => 'field_quickstart_icon',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => '2',
      'parent' => 'group_quickstart_info',
      '2' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      '3' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      'label' => array(
        'format' => 'hidden',
      ),
      'teaser' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      'token' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      '4' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'filefield',
    'required' => '0',
    'multiple' => '0',
    'module' => 'filefield',
    'active' => '1',
    'list_field' => '0',
    'list_default' => 1,
    'description_field' => '0',
    'widget' => array(
      'file_extensions' => 'png gif jpg jpeg',
      'file_path' => 'quickstarts',
      'progress_indicator' => 'bar',
      'max_filesize_per_file' => '',
      'max_filesize_per_node' => '',
      'max_resolution' => '256x256',
      'min_resolution' => '0',
      'alt' => '',
      'custom_alt' => 0,
      'title' => '',
      'custom_title' => 0,
      'title_type' => 'textfield',
      'default_image' => NULL,
      'use_default_image' => 0,
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
      'label' => 'Icon',
      'weight' => '2',
      'description' => 'An icon that will be used to represent this type.',
      'type' => 'imagefield_widget',
      'module' => 'imagefield',
    ),
  );

  // Exported field: field_quickstart_priority
  $fields['quickstart-field_quickstart_priority'] = array(
    'field_name' => 'field_quickstart_priority',
    'type_name' => 'quickstart',
    'display_settings' => array(
      'weight' => '31',
      'parent' => 'group_quickstart_admin',
      '2' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      '3' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'label' => array(
        'format' => 'hidden',
      ),
      'teaser' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'full' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      'token' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
      '4' => array(
        'format' => 'default',
        'exclude' => 1,
      ),
    ),
    'widget_active' => '1',
    'type' => 'number_integer',
    'required' => '0',
    'multiple' => '0',
    'module' => 'number',
    'active' => '1',
    'prefix' => '',
    'suffix' => '',
    'min' => '',
    'max' => '',
    'allowed_values' => '',
    'allowed_values_php' => '',
    'widget' => array(
      'default_value' => array(
        '0' => array(
          'value' => '',
          '_error_element' => 'default_value_widget][field_quickstart_priority][0][value',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Priority',
      'weight' => '31',
      'description' => 'Administrative option, gives this element higher priority in the visible display of the console.',
      'type' => 'number',
      'module' => 'number',
    ),
  );

  // Exported field: field_website
  $fields['quickstart-field_website'] = array(
    'field_name' => 'field_website',
    'type_name' => 'quickstart',
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
          'title' => '',
          'url' => '',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Website',
      'weight' => '1',
      'description' => 'A website for this quickstart',
      'type' => 'link',
      'module' => 'link',
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('Admin Tags');
  t('Cartridges');
  t('Git Repository URL');
  t('Icon');
  t('Language');
  t('Priority');
  t('Website');

  return $fields;
}
