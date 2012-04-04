<?php

/**
 * Implementation of hook_fieldgroup_default_groups().
 */
function video_fieldgroup_default_groups() {
  $groups = array();

  // Exported group: group_video_details
  $groups['video-group_video_details'] = array(
    'group_type' => 'standard',
    'type_name' => 'video',
    'group_name' => 'group_video_details',
    'label' => 'Video',
    'settings' => array(
      'form' => array(
        'style' => 'fieldset',
        'description' => '',
      ),
      'display' => array(
        'weight' => '-1',
        'label' => 'above',
        'teaser' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'full' => array(
          'format' => 'fieldset',
          'exclude' => 1,
        ),
        'description' => '',
        '4' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        '2' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        '3' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
        'token' => array(
          'format' => 'fieldset',
          'exclude' => 0,
        ),
      ),
    ),
    'weight' => '-1',
    'fields' => array(
      '0' => 'field_video_third_party',
      '1' => 'field_video_thumbnail',
      '2' => 'field_video_youku',
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('Video');

  return $groups;
}
