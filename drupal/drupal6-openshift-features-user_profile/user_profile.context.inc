<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function user_profile_context_default_contexts() {
  $export = array();

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'doc-owner-role';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'user' => array(
      'values' => array(
        'doc content owner' => 'doc content owner',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu-menu-doc-owner-menu' => array(
          'module' => 'menu',
          'delta' => 'menu-doc-owner-menu',
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['doc-owner-role'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-blogs';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'author' => 'author',
        'blog' => 'blog',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'blogs',
  );
  $context->condition_mode = 0;
  $export['menu-active-blogs'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-events';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'event' => 'event',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
    'path' => array(
      'values' => array(
        'calendar' => 'calendar',
        'calendar/*' => 'calendar/*',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'events',
  );
  $context->condition_mode = 0;
  $export['menu-active-events'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-faq';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'faq' => 'faq',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
    'path' => array(
      'values' => array(
        'faq/express-faq' => 'faq/express-faq',
        'faq/openshift-community-faq' => 'faq/openshift-community-faq',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'faq',
  );
  $context->condition_mode = 0;
  $export['menu-active-faq'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-forum';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums' => 'forums',
        'forums/*' => 'forums/*',
        'og' => 'og',
        'og/*' => 'og/*',
        'node/add/discussion/*' => 'node/add/discussion/*',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'node/1',
  );
  $context->condition_mode = 0;
  $export['menu-active-forum'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-ideas';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'idea' => 'idea',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'ideas',
  );
  $context->condition_mode = 0;
  $export['menu-active-ideas'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-kb';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'knowledge_base' => 'knowledge_base',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'kb',
  );
  $context->condition_mode = 0;
  $export['menu-active-kb'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'menu-active-wiki-page';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'wiki_page' => 'wiki_page',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'node/9475',
  );
  $context->condition_mode = 0;
  $export['menu-active-wiki-page'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'moderator-role';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'user' => array(
      'values' => array(
        'moderator' => 'moderator',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu-menu-moderator-menu' => array(
          'module' => 'menu',
          'delta' => 'menu-moderator-menu',
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['moderator-role'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'user-logged-in';
  $context->description = 'Displays blocks for users who are logged in.';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        '~admin' => '~admin',
        '~admin/*' => '~admin/*',
        '~forums' => '~forums',
      ),
    ),
    'user' => array(
      'values' => array(
        'authenticated user' => 'authenticated user',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu_block-1' => array(
          'module' => 'menu_block',
          'delta' => 1,
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
        'search-0' => array(
          'module' => 'search',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 1,
        ),
        'og-0' => array(
          'module' => 'og',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 2,
        ),
        'views-user_profile_box-block_1' => array(
          'module' => 'views',
          'delta' => 'user_profile_box-block_1',
          'region' => 'sidebar_left',
          'weight' => 3,
        ),
        'views-promotion_view-block_1' => array(
          'module' => 'views',
          'delta' => 'promotion_view-block_1',
          'region' => 'sidebar_left',
          'weight' => 4,
        ),
        'poll-0' => array(
          'module' => 'poll',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 5,
        ),
        'views-threads_by_popularity-block_1' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_1',
          'region' => 'sidebar_left',
          'weight' => 6,
        ),
        'views-threads_by_popularity-block_3' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_3',
          'region' => 'sidebar_left',
          'weight' => 7,
        ),
        'views-threads_by_popularity-block_2' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_2',
          'region' => 'sidebar_left',
          'weight' => 8,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays blocks for users who are logged in.');
  $export['user-logged-in'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'user-logged-in-forums-home-page';
  $context->description = 'Displays blocks for users who are logged in and on the forums home page.';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums' => 'forums',
      ),
    ),
    'user' => array(
      'values' => array(
        'authenticated user' => 'authenticated user',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu_block-1' => array(
          'module' => 'menu_block',
          'delta' => 1,
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
        'search-0' => array(
          'module' => 'search',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 1,
        ),
        'views-user_profile_box-block_1' => array(
          'module' => 'views',
          'delta' => 'user_profile_box-block_1',
          'region' => 'sidebar_left',
          'weight' => 2,
        ),
        'views-promotion_view-block_1' => array(
          'module' => 'views',
          'delta' => 'promotion_view-block_1',
          'region' => 'sidebar_left',
          'weight' => 3,
        ),
        'poll-0' => array(
          'module' => 'poll',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 4,
        ),
        'views-threads_by_popularity-block_1' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_1',
          'region' => 'sidebar_left',
          'weight' => 5,
        ),
        'views-threads_by_popularity-block_3' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_3',
          'region' => 'sidebar_left',
          'weight' => 6,
        ),
        'views-threads_by_popularity-block_2' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_2',
          'region' => 'sidebar_left',
          'weight' => 7,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays blocks for users who are logged in and on the forums home page.');
  $export['user-logged-in-forums-home-page'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'user-logged-out';
  $context->description = 'Displays blocks for anonymous uses.';
  $context->tag = '';
  $context->conditions = array(
    'user' => array(
      'values' => array(
        'anonymous user' => 'anonymous user',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'menu_block-1' => array(
          'module' => 'menu_block',
          'delta' => 1,
          'region' => 'sidebar_left',
          'weight' => 0,
        ),
        'search-0' => array(
          'module' => 'search',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 1,
        ),
        'views-promotion_view-block_1' => array(
          'module' => 'views',
          'delta' => 'promotion_view-block_1',
          'region' => 'sidebar_left',
          'weight' => 2,
        ),
        'views-threads_by_popularity-block_1' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_1',
          'region' => 'sidebar_left',
          'weight' => 3,
        ),
        'views-threads_by_popularity-block_3' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_3',
          'region' => 'sidebar_left',
          'weight' => 4,
        ),
        'views-threads_by_popularity-block_2' => array(
          'module' => 'views',
          'delta' => 'threads_by_popularity-block_2',
          'region' => 'sidebar_left',
          'weight' => 5,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays blocks for anonymous uses.');
  $export['user-logged-out'] = $context;

  return $export;
}
