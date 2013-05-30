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
          'region' => 'content_suffix',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['related-blog-posts'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'related-content';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'developers/java' => 'developers/java',
        'developers/jboss' => 'developers/jboss',
        'developers/php' => 'developers/php',
        'developers/zend' => 'developers/zend',
        'developers/ruby' => 'developers/ruby',
        'developers/node-js' => 'developers/node-js',
        'developers/python' => 'developers/python',
        'developers/mongodb' => 'developers/mongodb',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'views-related_content-block_3' => array(
          'module' => 'views',
          'delta' => 'related_content-block_3',
          'region' => 'content_suffix',
          'weight' => 0,
        ),
        'views-related_content-block_5' => array(
          'module' => 'views',
          'delta' => 'related_content-block_5',
          'region' => 'content_suffix',
          'weight' => 1,
        ),
        'views-related_content-block_2' => array(
          'module' => 'views',
          'delta' => 'related_content-block_2',
          'region' => 'content_suffix',
          'weight' => 2,
        ),
        'views-related_content-block_1' => array(
          'module' => 'views',
          'delta' => 'related_content-block_1',
          'region' => 'content_suffix',
          'weight' => 3,
        ),
        'views-related_content-block_4' => array(
          'module' => 'views',
          'delta' => 'related_content-block_4',
          'region' => 'content_suffix',
          'weight' => 4,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['related-content'] = $context;

  return $export;
}
