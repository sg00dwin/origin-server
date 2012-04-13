<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function global_settings_context_default_contexts() {
  $export = array();

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'footer-region';
  $context->description = 'This is a sitewide context that adds menus to the footer.';
  $context->tag = '';
  $context->conditions = array(
    'sitewide' => array(
      'values' => array(
        1 => 1,
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu-menu-top-footer-menu' => array(
          'module' => 'menu',
          'delta' => 'menu-top-footer-menu',
          'region' => 'footer_top',
          'weight' => 0,
        ),
        'menu-menu-copyright-menu' => array(
          'module' => 'menu',
          'delta' => 'menu-copyright-menu',
          'region' => 'footer_bottom',
          'weight' => 0,
        ),
        'menu-menu-bottom-footer-menu' => array(
          'module' => 'menu',
          'delta' => 'menu-bottom-footer-menu',
          'region' => 'footer_bottom',
          'weight' => 1,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('This is a sitewide context that adds menus to the footer.');
  $export['footer-region'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'sitewide';
  $context->description = 'This context adds most blocks that should appear sitewide.';
  $context->tag = '';
  $context->conditions = array(
    'sitewide' => array(
      'values' => array(
        1 => 1,
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'block-1' => array(
          'module' => 'block',
          'delta' => 1,
          'region' => 'header_right',
          'weight' => 0,
        ),
        'menu-primary-links' => array(
          'module' => 'menu',
          'delta' => 'primary-links',
          'region' => 'header_menu',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('This context adds most blocks that should appear sitewide.');
  $export['sitewide'] = $context;

  return $export;
}
