<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function forums_context_default_contexts() {
  $export = array();
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'default-title-bar';
  $context->description = 'Displays the default title bar';
  $context->tag = '';
  $context->conditions = array(
    'sitewide' => array(
      'values' => array(
        1 => 1,
      ),
    ),
  );
  $context->reactions = array(
    'theme' => array(
      'title' => 'Community',
      'subtitle' => 'Interact and Exchange with other Users',
      'class' => '',
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays the default title bar');

  $export['default-title-bar'] = $context;
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'express-title-bar';
  $context->description = 'Displays the Express title bar if the user is in that section';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums/express' => 'forums/express',
        'forums/express/*' => 'forums/express/*',
        'node/add/discussion/express*' => 'node/add/discussion/express*',
      ),
    ),
  );
  $context->reactions = array(
    'theme' => array(
      'title' => 'Express Forum',
      'subtitle' => 'Talk with other Express Users',
      'class' => '',
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays the Express title bar if the user is in that section');

  $export['express-title-bar'] = $context;
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'flex-title-bar';
  $context->description = 'Displays the Flex title bar if the user is in that section';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums/flex' => 'forums/flex',
        'forums/flex/*' => 'forums/flex/*',
        'node/add/discussion/flex*' => 'node/add/discussion/flex*',
      ),
    ),
  );
  $context->reactions = array(
    'theme' => array(
      'title' => 'Flex Forum',
      'subtitle' => 'Talk with other Flex Users',
      'class' => '',
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays the Flex title bar if the user is in that section');

  $export['flex-title-bar'] = $context;
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'news-and-announcements-title-bar';
  $context->description = 'Displays the News and Announcements title bar if the user is in that section';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums/news-and-announcements' => 'forums/news-and-announcements',
        'forums/news-and-announcements/*' => 'forums/news-and-announcements/*',
        'node/add/discussion/news-and-announcements*' => 'node/add/discussion/news-and-announcements*',
      ),
    ),
  );
  $context->reactions = array(
    'theme' => array(
      'title' => 'News and Announcements',
      'subtitle' => 'Get all the latest information on the cloud',
      'class' => '',
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays the News and Announcements title bar if the user is in that section');

  $export['news-and-announcements-title-bar'] = $context;
  return $export;
}
