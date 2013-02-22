#!/bin/bash
set +e

gem install ruby-mysql --no-rdoc --no-ri
pushd /usr/share/drupal6
drush cc all 'module list'
drush features
drush fr application_quickstarts user_profile redhat_events blogs forums -y
drush cc menu
/etc/drupal6/all/modules/custom/redhat_sso/migrate-names.rb
/etc/drupal6/all/modules/custom/redhat_sso/migrate-content.rb
service httpd restart
drush cron
