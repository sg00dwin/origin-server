<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function blogs_context_default_contexts() {
  $export = array();

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'related-blog-posts';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'blog' => 'blog',
      ),
      'options' => array(
        'node_form' => '0',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'views-nodes_by_category-block_2' => array(
          'module' => 'views',
          'delta' => 'nodes_by_category-block_2',
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['related-blog-posts'] = $context;

  return $export;
}
