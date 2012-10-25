<?php

/**
 * Implementation of hook_taxonomy_default_vocabularies().
 */
function application_quickstarts_taxonomy_default_vocabularies() {
  return array(
    'quickstart_tags' => array(
      'name' => 'Quickstart Tags',
      'description' => 'Describe and categorize application quickstarts with tags',
      'help' => '',
      'relations' => '1',
      'hierarchy' => '0',
      'multiple' => '0',
      'required' => '0',
      'tags' => '1',
      'module' => 'features_quickstart_tags',
      'weight' => '0',
      'nodes' => array(
        'quickstart' => 'quickstart',
      ),
    ),
  );
}
