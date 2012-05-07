#!/bin/bash

pushd /usr/share/drupal6
drush fr blogs community_wiki forums front_page global_settings recent_activity_report redhat_events redhat_ideas reporting_csv_views rules_by_category user_profile video
