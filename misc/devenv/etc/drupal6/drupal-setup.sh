#!/bin/bash

pushd /usr/share/drupal6

#Setup the administrative password to the default
drush user-password admin --password="admin"

#Ensure there is a sample test user
drush user-create test --mail="test@test.com" --password="test"

set -e
mv /usr/share/drupal6/robots.txt{,.old}
set +e
ln -s /etc/drupal6/all/themes/openshift-theme/robots.txt /usr/share/drupal6/robots.txt
ln -s /var/www/html/favicon.ico /usr/share/drupal6/favicon.ico

echo "Restarting 'httpd' to pick up change to admin password"
service httpd restart
