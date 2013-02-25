<?php

/**
 * Implementation of hook_fieldgroup_default_groups().
 */
function application_quickstarts_fieldgroup_default_groups() {
  $groups = array();

  // Exported group: group_quickstart_admin
  $groups['quickstart-group_quickstart_admin'] = array(
    'group_type' => 'standard',
    'type_name' => 'quickstart',
    'group_name' => 'group_quickstart_admin',
    'label' => 'Quickstart Admin',
    'settings' => array(
      'form' => array(
        'style' => 'fieldset',
        'description' => '',
      ),
      'display' => array(
        'weight' => '-2',
        '2' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        '3' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'label' => 'hidden',
        'teaser' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'full' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'token' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        '4' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'description' => '',
      ),
    ),
    'weight' => '-4',
    'fields' => array(
      '0' => 'field_quickstart_trust',
      '1' => 'field_quickstart_priority',
      '2' => 'field_quickstart_admin_tags',
    ),
  );

  // Exported group: group_quickstart_info
  $groups['quickstart-group_quickstart_info'] = array(
    'group_type' => 'standard',
    'type_name' => 'quickstart',
    'group_name' => 'group_quickstart_info',
    'label' => 'Quickstart Info',
    'settings' => array(
      'form' => array(
        'style' => 'fieldset',
        'description' => '',
      ),
      'display' => array(
        'weight' => '-3',
        '2' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        '3' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        'label' => 'above',
        'teaser' => array(
          'format' => 'simple',
          'exclude' => 0,
        ),
        'full' => array(
          'format' => 'simple',
          'exclude' => 0,
        ),
        'token' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        '4' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        'description' => '',
      ),
    ),
    'weight' => '-6',
    'fields' => array(
      '0' => 'field_code_language',
      '1' => 'field_website',
      '2' => 'field_quickstart_icon',
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('Quickstart Admin');
  t('Quickstart Info');

  return $groups;
}
