<?php

/**
 * Implementation of hook_node_info().
 */
function community_wiki_node_info() {
  $items = array(
    'wiki_page' => array(
      'name' => t('Wiki Page'),
      'module' => 'features',
      'description' => t('A wiki page using MediaWiki syntax that links to other content'),
      'has_title' => '1',
      'title_label' => t('Name'),
      'has_body' => '1',
      'body_label' => t('Content'),
      'min_word_count' => '0',
      'help' => '',
    ),
  );
  return $items;
}
