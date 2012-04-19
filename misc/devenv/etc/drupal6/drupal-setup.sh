#!/bin/bash

#Setup the administrative password to the default
drush user-password admin --password="admin"

#Enable the garland theme for use by the admin
drush en views_ui markdown garland menu_block context_ui context_layouts community_wiki views_export geshifield geshifilter

#Ensure there is a sample test user
drush user-create test --mail="test@test.com" --password="test"

