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
          'weight' => 30,
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
  $context->name = 'menu-active-community';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'author' => 'author',
        'newsletter' => 'newsletter',
        'poll' => 'poll',
        'promotion_blocks' => 'promotion_blocks',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
    'user_page' => array(
      'values' => array(
        'form' => 'form',
        'register' => 'register',
        'view' => 'view',
      ),
      'options' => array(
        'mode' => 'all',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => '<front>',
  );
  $context->condition_mode = 0;
  $export['menu-active-community'] = $context;

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
    'views' => array(
      'values' => array(
        'Ideas' => 'Ideas',
        'Ideas:page_1' => 'Ideas:page_1',
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
  $context->name = 'menu-active-videos';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'video' => 'video',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
    'views' => array(
      'values' => array(
        'nodes_by_category:page_5' => 'nodes_by_category:page_5',
      ),
    ),
  );
  $context->reactions = array(
    'menu' => 'videos',
  );
  $context->condition_mode = 0;
  $export['menu-active-videos'] = $context;

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
  $context->name = 'messaging-community';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        '<front>' => '<front>',
      ),
    ),
    'user' => array(
      'values' => array(
        'anonymous user' => 'anonymous user',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'block-2' => array(
          'module' => 'user_profile',
          'delta' => 'community-messaging',
          'region' => 'messaging',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;
  $export['messaging-community'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'messaging-developer-center';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'developers' => 'developers',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'block-3' => array(
          'module' => 'user_profile',
          'delta' => 'developer-center-messaging',
          'region' => 'messaging',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;
  $export['messaging-developer-center'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'messaging-get-started';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'get-started' => 'get-started',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'user_profile-get-started-messaging' => array(
          'module' => 'user_profile',
          'delta' => 'get-started-messaging',
          'region' => 'messaging',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;
  $export['messaging-get-started'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'messaging-learn-more';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'paas' => 'paas',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'user_profile-learn-more-messaging' => array(
          'module' => 'user_profile',
          'delta' => 'learn-more-messaging',
          'region' => 'messaging',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['messaging-learn-more'] = $context;

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
          'weight' => 50,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['moderator-role'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'recent-changes-sidebar';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'menu' => array(
      'values' => array(
        'documentation' => 'documentation',
        'faq' => 'faq',
        'kb' => 'kb',
        'node/10295' => 'node/10295',
        'node/10863' => 'node/10863',
        'node/5085' => 'node/5085',
        'node/5475' => 'node/5475',
        'node/9435' => 'node/9435',
        'node/9445' => 'node/9445',
        'node/9515' => 'node/9515',
        'node/9525' => 'node/9525',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'views-nodes_by_category-block_3' => array(
          'module' => 'views',
          'delta' => 'nodes_by_category-block_3',
          'region' => 'sidebar_left',
          'weight' => 20,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['recent-changes-sidebar'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'user-logged-in';
  $context->description = 'Displays blocks for users who are logged in.';
  $context->tag = '';
  $context->conditions = array(
    'menu' => array(
      'values' => array(
        '<front>' => '<front>',
      ),
    ),
    'path' => array(
      'values' => array(
        '<front>' => '<front>',
        'home' => 'home',
        'user' => 'user',
        'user/*' => 'user/*',
        'forums/*' => 'forums/*',
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
        'views-user_profile_box-block_1' => array(
          'module' => 'views',
          'delta' => 'user_profile_box-block_1',
          'region' => 'sidebar_left',
          'weight' => 30,
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
  );
  $context->reactions = array();
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
  $context->conditions = array();
  $context->reactions = array();
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Displays blocks for anonymous uses.');
  $export['user-logged-out'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'viewing-hierarchy';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'menu' => array(
      'values' => array(
        '<front>' => '<front>',
        'node/9435' => 'node/9435',
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
          'weight' => -10,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;
  $export['viewing-hierarchy'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'viewing-poll';
  $context->description = '';
  $context->tag = '';
  $context->conditions = array(
    'path' => array(
      'values' => array(
        'forums/*' => 'forums/*',
        '<front>' => '<front>',
        'ideas' => 'ideas',
        'videos' => 'videos',
        'ideas/*' => 'ideas/*',
        'events' => 'events',
        'events/*' => 'events/*',
        'blogs' => 'blogs',
        'get-involved' => 'get-involved',
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
        'poll-0' => array(
          'module' => 'poll',
          'delta' => 0,
          'region' => 'sidebar_left',
          'weight' => 20,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;
  $export['viewing-poll'] = $context;

  return $export;
}
