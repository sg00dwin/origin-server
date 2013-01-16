<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function application_quickstarts_context_default_contexts() {
  $export = array();

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'viewing-quickstarts';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'quickstarts' => 'quickstarts',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'application_quickstarts-0' => array(
          'module' => 'application_quickstarts',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;
  $export['viewing-quickstarts'] = $context;

  return $export;
}
