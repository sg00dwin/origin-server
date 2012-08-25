<?php

/**
 * Implementation of hook_views_default_views().
 */
function redhat_events_views_default_views() {
  $views = array();

  // Exported view: event_calendar
  $view = new view;
  $view->name = 'event_calendar';
  $view->description = 'A multi-dimensional calendar view with back/next navigation.';
  $view->tag = 'Calendar';
  $view->base_table = 'node';
  $view->core = 6;
  $view->api_version = '2';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  $handler = $view->new_display('default', 'Defaults', 'default');
  $handler->override_option('fields', array(
    'field_event_url_url' => array(
      'label' => 'URL',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'widget',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 1,
      'id' => 'field_event_url_url',
      'table' => 'node_data_field_event_url',
      'field' => 'field_event_url_url',
      'relationship' => 'none',
    ),
    'title' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '[field_event_url_url]',
        'make_link' => 1,
        'path' => '[field_event_url_url]',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '_blank',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'exclude' => 0,
      'id' => 'title',
      'field' => 'title',
      'table' => 'node',
      'relationship' => 'none',
    ),
    'changed' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'date_format' => 'small',
      'custom_date_format' => '',
      'exclude' => 1,
      'link_to_node' => 0,
      'id' => 'changed',
      'field' => 'changed',
      'table' => 'node',
      'relationship' => 'none',
    ),
    'field_event_start_date_value' => array(
      'label' => 'Start Date',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'widget',
      'format' => 'short',
      'multiple' => array(
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_to' => '',
        'group' => TRUE,
      ),
      'repeat' => array(
        'show_repeat_rule' => '',
      ),
      'fromto' => array(
        'fromto' => 'both',
      ),
      'exclude' => 1,
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
    'field_event_end_date_value' => array(
      'label' => 'End Date',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'widget',
      'format' => 'default',
      'multiple' => array(
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_to' => '',
        'group' => TRUE,
      ),
      'repeat' => array(
        'show_repeat_rule' => '',
      ),
      'fromto' => array(
        'fromto' => 'both',
      ),
      'exclude' => 1,
      'id' => 'field_event_end_date_value',
      'table' => 'node_data_field_event_end_date',
      'field' => 'field_event_end_date_value',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('sorts', array(
    'changed' => array(
      'order' => 'ASC',
      'delta' => '-1',
      'id' => 'changed',
      'table' => 'node',
      'field' => 'changed',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('arguments', array(
    'date_argument' => array(
      'default_action' => 'default',
      'style_plugin' => 'default_summary',
      'style_options' => array(),
      'wildcard' => 'all',
      'wildcard_substitution' => 'All',
      'title' => '',
      'breadcrumb' => '',
      'default_argument_type' => 'date',
      'default_argument' => '',
      'validate_type' => 'none',
      'validate_fail' => 'not found',
      'date_fields' => array(
        'node_data_field_event_end_date.field_event_end_date_value' => 'node_data_field_event_end_date.field_event_end_date_value',
        'node_data_field_event_start_date.field_event_start_date_value' => 'node_data_field_event_start_date.field_event_start_date_value',
      ),
      'year_range' => '-3:+3',
      'date_method' => 'OR',
      'granularity' => 'month',
      'id' => 'date_argument',
      'table' => 'node',
      'field' => 'date_argument',
      'relationship' => 'none',
      'default_argument_user' => 0,
      'default_argument_fixed' => '',
      'default_argument_php' => '',
      'validate_argument_node_type' => array(
        'poll' => 0,
        'event' => 0,
        'idea' => 0,
        'faq' => 0,
        'author' => 0,
        'blog' => 0,
        'discussion' => 0,
        'group' => 0,
        'document' => 0,
        'knowledge_base' => 0,
        'page' => 0,
        'promotion_blocks' => 0,
        'video' => 0,
        'story' => 0,
      ),
      'validate_argument_node_access' => 0,
      'validate_argument_nid_type' => 'nid',
      'validate_argument_vocabulary' => array(
        2 => 0,
        1 => 0,
      ),
      'validate_argument_type' => 'tid',
      'validate_argument_php' => '',
      'override' => array(
        'button' => 'Override',
      ),
      'default_options_div_prefix' => '',
      'validate_user_argument_type' => 'uid',
      'validate_user_roles' => array(
        2 => 0,
        3 => 0,
        15 => 0,
        5 => 0,
        4 => 0,
      ),
      'default_taxonomy_tid_term_page' => 0,
      'default_taxonomy_tid_node' => 0,
      'default_taxonomy_tid_limit' => 0,
      'default_taxonomy_tid_vids' => array(
        2 => 0,
        1 => 0,
      ),
      'validate_argument_transform' => 0,
      'validate_user_restrict_roles' => 0,
      'validate_argument_node_flag_name' => '*relationship*',
      'validate_argument_node_flag_test' => 'flaggable',
      'validate_argument_node_flag_id_type' => 'id',
      'validate_argument_user_flag_name' => '*relationship*',
      'validate_argument_user_flag_test' => 'flaggable',
      'validate_argument_user_flag_id_type' => 'id',
      'validate_argument_is_member' => 'OG_VIEWS_DO_NOT_VALIDATE_MEMBERSHIP',
      'validate_argument_group_node_type' => array(
        'group' => 0,
      ),
    ),
  ));
  $handler->override_option('filters', array(
    'status' => array(
      'operator' => '=',
      'value' => 1,
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'id' => 'status',
      'table' => 'node',
      'field' => 'status',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('access', array(
    'type' => 'none',
    'role' => array(),
    'perm' => '',
  ));
  $handler->override_option('cache', array(
    'type' => 'none',
  ));
  $handler->override_option('title', 'Calendar');
  $handler->override_option('header', '<ul class=\'nav nav-pills\'>
<li><a href=\'events?sort=country\'>View By Country</a></li>
<li><a href=\'events\'>View By Date</a></li>
</ul>');
  $handler->override_option('header_format', '2');
  $handler->override_option('header_empty', 1);
  $handler->override_option('items_per_page', 0);
  $handler->override_option('use_more', 0);
  $handler->override_option('style_plugin', 'calendar_nav');
  $handler = $view->new_display('calendar', 'Calendar page', 'calendar_1');
  $handler->override_option('style_options', NULL);
  $handler->override_option('row_plugin', '');
  $handler->override_option('row_options', NULL);
  $handler->override_option('path', 'calendar');
  $handler->override_option('menu', array(
    'type' => 'none',
    'title' => '',
    'description' => '',
    'weight' => 0,
    'name' => 'navigation',
  ));
  $handler->override_option('tab_options', array(
    'type' => 'none',
    'title' => '',
    'description' => '',
    'weight' => 0,
    'name' => 'navigation',
  ));
  $handler->override_option('calendar_colors', array(
    0 => array(),
  ));
  $handler->override_option('calendar_colors_vocabulary', array());
  $handler->override_option('calendar_colors_taxonomy', array());
  $handler->override_option('calendar_colors_group', array());
  $handler->override_option('calendar_popup', 0);
  $handler->override_option('calendar_date_link', '');
  $handler = $view->new_display('calendar_block', 'Calendar block', 'calendar_block_1');
  $handler->override_option('style_options', NULL);
  $handler->override_option('row_plugin', '');
  $handler->override_option('row_options', NULL);
  $handler->override_option('block_description', 'Calendar');
  $handler->override_option('block_caching', -1);
  $handler = $view->new_display('calendar_period', 'Year view', 'calendar_period_1');
  $handler->override_option('style_plugin', 'calendar_style');
  $handler->override_option('style_options', array(
    'display_type' => 'year',
    'name_size' => 1,
    'max_items' => 0,
  ));
  $handler->override_option('attachment_position', 'after');
  $handler->override_option('inherit_arguments', TRUE);
  $handler->override_option('inherit_exposed_filters', TRUE);
  $handler->override_option('inherit_pager', FALSE);
  $handler->override_option('render_pager', TRUE);
  $handler->override_option('displays', array(
    'calendar_1' => 'calendar_1',
    'default' => 0,
    'calendar_block_1' => 0,
  ));
  $handler->override_option('calendar_type', 'year');
  $handler = $view->new_display('calendar_period', 'Month view', 'calendar_period_2');
  $handler->override_option('style_plugin', 'calendar_style');
  $handler->override_option('style_options', array(
    'display_type' => 'month',
    'name_size' => '99',
    'with_weekno' => '1',
    'date_fields' => NULL,
    'max_items' => 0,
  ));
  $handler->override_option('attachment_position', 'after');
  $handler->override_option('inherit_arguments', TRUE);
  $handler->override_option('inherit_exposed_filters', TRUE);
  $handler->override_option('inherit_pager', FALSE);
  $handler->override_option('render_pager', TRUE);
  $handler->override_option('displays', array(
    'calendar_1' => 'calendar_1',
    'default' => 0,
    'calendar_block_1' => 0,
  ));
  $handler->override_option('calendar_type', 'month');
  $handler = $view->new_display('calendar_period', 'Day view', 'calendar_period_3');
  $handler->override_option('style_plugin', 'calendar_style');
  $handler->override_option('style_options', array(
    'name_size' => '99',
    'with_weekno' => 0,
    'max_items' => 0,
    'max_items_behavior' => 'more',
    'groupby_times' => 'hour',
    'groupby_times_custom' => '',
    'groupby_field' => '',
  ));
  $handler->override_option('attachment_position', 'after');
  $handler->override_option('inherit_arguments', TRUE);
  $handler->override_option('inherit_exposed_filters', TRUE);
  $handler->override_option('inherit_pager', FALSE);
  $handler->override_option('render_pager', TRUE);
  $handler->override_option('displays', array(
    'calendar_1' => 'calendar_1',
    'default' => 0,
    'calendar_block_1' => 0,
  ));
  $handler->override_option('calendar_type', 'day');
  $handler = $view->new_display('calendar_period', 'Week view', 'calendar_period_4');
  $handler->override_option('style_plugin', 'calendar_style');
  $handler->override_option('style_options', array(
    'name_size' => '99',
    'with_weekno' => 0,
    'max_items' => 0,
    'max_items_behavior' => 'more',
    'groupby_times' => 'hour',
    'groupby_times_custom' => '',
    'groupby_field' => '',
  ));
  $handler->override_option('attachment_position', 'after');
  $handler->override_option('inherit_arguments', TRUE);
  $handler->override_option('inherit_exposed_filters', TRUE);
  $handler->override_option('inherit_pager', FALSE);
  $handler->override_option('render_pager', TRUE);
  $handler->override_option('displays', array(
    'calendar_1' => 'calendar_1',
    'default' => 0,
    'calendar_block_1' => 0,
  ));
  $handler->override_option('calendar_type', 'week');
  $handler = $view->new_display('calendar_period', 'Block view', 'calendar_period_5');
  $handler->override_option('style_plugin', 'calendar_style');
  $handler->override_option('style_options', array(
    'display_type' => 'month',
    'name_size' => '1',
  ));
  $handler->override_option('attachment_position', 'after');
  $handler->override_option('inherit_arguments', TRUE);
  $handler->override_option('inherit_exposed_filters', TRUE);
  $handler->override_option('inherit_pager', FALSE);
  $handler->override_option('render_pager', TRUE);
  $handler->override_option('displays', array(
    'calendar_1' => 0,
    'default' => 0,
    'calendar_block_1' => 'calendar_block_1',
  ));
  $handler->override_option('calendar_type', 'month');
  $handler = $view->new_display('block', 'Upcoming', 'block_1');
  $handler->override_option('fields', array(
    'title' => array(
      'label' => '',
      'link_to_node' => 1,
      'exclude' => 0,
      'id' => 'title',
      'field' => 'title',
      'table' => 'node',
      'relationship' => 'none',
      'format' => 'default',
    ),
    'changed' => array(
      'label' => '',
      'link_to_node' => 0,
      'exclude' => 0,
      'id' => 'changed',
      'field' => 'changed',
      'table' => 'node',
      'relationship' => 'none',
      'date_format' => 'small',
      'format' => 'default',
    ),
  ));
  $handler->override_option('arguments', array());
  $handler->override_option('filters', array(
    'status' => array(
      'operator' => '=',
      'value' => 1,
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'id' => 'status',
      'table' => 'node',
      'field' => 'status',
      'relationship' => 'none',
    ),
    'date_filter' => array(
      'operator' => '>=',
      'value' => array(
        'value' => NULL,
        'min' => NULL,
        'max' => NULL,
        'default_date' => 'now',
        'default_to_date' => '',
      ),
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'date_fields' => array(
        'node.changed' => 'node.changed',
      ),
      'granularity' => 'day',
      'form_type' => 'date_select',
      'default_date' => 'now',
      'default_to_date' => '',
      'id' => 'date_filter',
      'table' => 'node',
      'field' => 'date_filter',
      'override' => array(
        'button' => 'Use default',
      ),
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('title', 'Upcoming');
  $handler->override_option('items_per_page', 5);
  $handler->override_option('use_more', 1);
  $handler->override_option('style_plugin', 'list');
  $handler->override_option('style_options', array(
    'grouping' => '',
    'type' => 'ul',
  ));
  $handler->override_option('block_description', 'Upcoming');
  $handler->override_option('block_caching', -1);

  $views[$view->name] = $view;

  // Exported view: event_view
  $view = new view;
  $view->name = 'event_view';
  $view->description = 'Events formatted by content';
  $view->tag = '';
  $view->base_table = 'node';
  $view->core = 6;
  $view->api_version = '2';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  $handler = $view->new_display('default', 'Defaults', 'default');
  $handler->override_option('fields', array(
    'field_event_url_url' => array(
      'label' => 'URL',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'widget',
      'format' => 'plain',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 1,
      'id' => 'field_event_url_url',
      'table' => 'node_data_field_event_url',
      'field' => 'field_event_url_url',
      'relationship' => 'none',
    ),
    'title' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 1,
        'path' => '[field_event_url_url]',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '<b>',
        'suffix' => '</b>',
        'target' => '_blank',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'exclude' => 0,
      'id' => 'title',
      'table' => 'node',
      'field' => 'title',
      'relationship' => 'none',
    ),
    'field_event_online_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 1,
        'text' => 'Online',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_online_value',
      'table' => 'node_data_field_event_online',
      'field' => 'field_event_online_value',
      'relationship' => 'none',
      'override' => array(
        'button' => 'Override',
      ),
    ),
    'field_event_city_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_city_value',
      'table' => 'node_data_field_event_city',
      'field' => 'field_event_city_value',
      'relationship' => 'none',
    ),
    'field_event_state_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 1,
        'text' => ', [field_event_state_value]',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'custom',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_state_value',
      'table' => 'node_data_field_event_state',
      'field' => 'field_event_state_value',
      'relationship' => 'none',
    ),
    'field_event_country_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_country_value',
      'table' => 'node_data_field_event_country',
      'field' => 'field_event_country_value',
      'relationship' => 'none',
    ),
    'field_event_start_date_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '15',
        'word_boundary' => 0,
        'ellipsis' => 0,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'long',
      'multiple' => array(
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_to' => '',
        'group' => TRUE,
      ),
      'repeat' => array(
        'show_repeat_rule' => '',
      ),
      'fromto' => array(
        'fromto' => 'both',
      ),
      'exclude' => 0,
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('sorts', array(
    'field_event_start_date_value' => array(
      'order' => 'ASC',
      'delta' => -1,
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('filters', array(
    'type' => array(
      'operator' => 'in',
      'value' => array(
        'event' => 'event',
      ),
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'id' => 'type',
      'table' => 'node',
      'field' => 'type',
      'relationship' => 'none',
    ),
    'field_event_start_date_value' => array(
      'operator' => '>=',
      'value' => array(
        'value' => NULL,
        'min' => NULL,
        'max' => NULL,
        'default_date' => 'today',
        'default_to_date' => '',
      ),
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'date_fields' => array(
        'node_data_field_event_start_date.field_event_start_date_value' => 'node_data_field_event_start_date.field_event_start_date_value',
      ),
      'date_method' => 'AND',
      'granularity' => 'day',
      'form_type' => 'date_select',
      'default_date' => 'today',
      'default_to_date' => '',
      'year_range' => '-3:+3',
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
    'field_event_start_date_value_1' => array(
      'operator' => '<',
      'value' => array(
        'value' => NULL,
        'min' => NULL,
        'max' => NULL,
        'default_date' => '3 months',
        'default_to_date' => '',
      ),
      'group' => '0',
      'exposed' => FALSE,
      'expose' => array(
        'operator' => FALSE,
        'label' => '',
      ),
      'date_fields' => array(
        'node_data_field_event_start_date.field_event_start_date_value' => 'node_data_field_event_start_date.field_event_start_date_value',
      ),
      'date_method' => 'AND',
      'granularity' => 'day',
      'form_type' => 'date_select',
      'default_date' => '3 months',
      'default_to_date' => '',
      'year_range' => '-3:+3',
      'id' => 'field_event_start_date_value_1',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('access', array(
    'type' => 'none',
  ));
  $handler->override_option('cache', array(
    'type' => 'none',
  ));
  $handler->override_option('css_class', 'event-listings');
  $handler->override_option('items_per_page', 0);
  $handler->override_option('style_options', array(
    'grouping' => '',
  ));
  $handler->override_option('row_options', array(
    'inline' => array(
      'field_event_online_value' => 'field_event_online_value',
      'field_event_city_value' => 'field_event_city_value',
      'field_event_state_value' => 'field_event_state_value',
      'field_event_country_value' => 'field_event_country_value',
      'field_event_end_date_value' => 'field_event_end_date_value',
    ),
    'separator' => '',
    'hide_empty' => 0,
  ));
  $handler = $view->new_display('block', 'Events by Date block', 'block_1');
  $handler->override_option('block_description', '');
  $handler->override_option('block_caching', -1);
  $handler = $view->new_display('block', 'Events by Country block', 'block_2');
  $handler->override_option('sorts', array(
    'field_event_country_value' => array(
      'order' => 'ASC',
      'delta' => -1,
      'id' => 'field_event_country_value',
      'table' => 'node_data_field_event_country',
      'field' => 'field_event_country_value',
      'override' => array(
        'button' => 'Use default',
      ),
      'relationship' => 'none',
    ),
    'field_event_start_date_value' => array(
      'order' => 'ASC',
      'delta' => -1,
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
    ),
  ));
  $handler->override_option('style_options', array(
    'grouping' => 'field_event_country_value',
  ));
  $handler->override_option('row_options', array(
    'inline' => array(
      'field_event_online_value' => 'field_event_online_value',
      'field_event_city_value' => 'field_event_city_value',
      'field_event_state_value' => 'field_event_state_value',
      'field_event_country_value' => 'field_event_country_value',
      'field_event_end_date_value' => 'field_event_end_date_value',
    ),
    'separator' => '',
    'hide_empty' => 1,
  ));
  $handler->override_option('block_description', '');
  $handler->override_option('block_caching', -1);
  $handler = $view->new_display('block', 'Front page Recent Events block', 'block_3');
  $handler->override_option('fields', array(
    'field_event_url_url' => array(
      'label' => 'URL',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 0,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'widget',
      'format' => 'plain',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 1,
      'id' => 'field_event_url_url',
      'table' => 'node_data_field_event_url',
      'field' => 'field_event_url_url',
      'relationship' => 'none',
    ),
    'title' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 1,
        'path' => '[field_event_url_url]',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '_blank',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'exclude' => 0,
      'id' => 'title',
      'table' => 'node',
      'field' => 'title',
      'relationship' => 'none',
    ),
    'field_event_online_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 1,
        'text' => 'Online',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_online_value',
      'table' => 'node_data_field_event_online',
      'field' => 'field_event_online_value',
      'relationship' => 'none',
    ),
    'field_event_city_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_city_value',
      'table' => 'node_data_field_event_city',
      'field' => 'field_event_city_value',
      'relationship' => 'none',
      'override' => array(
        'button' => 'Use default',
      ),
    ),
    'field_event_state_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'default',
      'multiple' => array(
        'group' => TRUE,
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_reversed' => FALSE,
      ),
      'exclude' => 0,
      'id' => 'field_event_state_value',
      'table' => 'node_data_field_event_state',
      'field' => 'field_event_state_value',
      'relationship' => 'none',
      'override' => array(
        'button' => 'Use default',
      ),
    ),
    'field_event_start_date_value' => array(
      'label' => '',
      'alter' => array(
        'alter_text' => 0,
        'text' => '',
        'make_link' => 0,
        'path' => '',
        'absolute' => 0,
        'link_class' => '',
        'alt' => '',
        'rel' => '',
        'prefix' => '',
        'suffix' => '',
        'target' => '',
        'help' => '',
        'trim' => 0,
        'max_length' => '',
        'word_boundary' => 1,
        'ellipsis' => 1,
        'html' => 0,
        'strip_tags' => 0,
      ),
      'empty' => '',
      'hide_empty' => 1,
      'empty_zero' => 0,
      'hide_alter_empty' => 1,
      'link_to_node' => 0,
      'label_type' => 'none',
      'format' => 'long',
      'multiple' => array(
        'multiple_number' => '',
        'multiple_from' => '',
        'multiple_to' => '',
        'group' => TRUE,
      ),
      'repeat' => array(
        'show_repeat_rule' => '',
      ),
      'fromto' => array(
        'fromto' => 'both',
      ),
      'exclude' => 0,
      'id' => 'field_event_start_date_value',
      'table' => 'node_data_field_event_start_date',
      'field' => 'field_event_start_date_value',
      'relationship' => 'none',
      'override' => array(
        'button' => 'Use default',
      ),
    ),
  ));
  $handler->override_option('cache', array(
    'type' => 'time',
    'results_lifespan' => '3600',
    'output_lifespan' => '3600',
  ));
  $handler->override_option('items_per_page', 5);
  $handler->override_option('style_plugin', 'table');
  $handler->override_option('style_options', array(
    'grouping' => '',
    'override' => 1,
    'sticky' => 0,
    'order' => 'asc',
    'summary' => '',
    'columns' => array(
      'field_event_url_url' => 'field_event_url_url',
      'title' => 'title',
      'field_event_online_value' => 'field_event_city_value',
      'field_event_city_value' => 'field_event_city_value',
      'field_event_state_value' => 'field_event_city_value',
      'field_event_start_date_value' => 'field_event_start_date_value',
    ),
    'info' => array(
      'field_event_url_url' => array(
        'sortable' => 0,
        'separator' => '',
      ),
      'title' => array(
        'sortable' => 0,
        'separator' => '',
      ),
      'field_event_online_value' => array(
        'sortable' => 0,
        'separator' => '',
      ),
      'field_event_city_value' => array(
        'sortable' => 0,
        'separator' => ', ',
      ),
      'field_event_state_value' => array(
        'sortable' => 0,
        'separator' => '',
      ),
      'field_event_start_date_value' => array(
        'sortable' => 0,
        'separator' => '',
      ),
    ),
    'default' => '-1',
  ));
  $handler->override_option('row_options', array(
    'inline' => array(
      'field_event_city_value' => 'field_event_city_value',
      'field_event_state_value' => 'field_event_state_value',
    ),
    'separator' => ',',
    'hide_empty' => 0,
  ));
  $handler->override_option('block_description', '');
  $handler->override_option('block_caching', '8');

  $views[$view->name] = $view;

  return $views;
}
