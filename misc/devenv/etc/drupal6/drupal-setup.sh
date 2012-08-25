#!/bin/bash

pushd /usr/share/drupal6

#Setup the administrative password to the default
drush user-password admin --password="admin"

#Ensure there is a sample test user
drush user-create test --mail="test@test.com" --password="test"

echo "Restarting 'httpd' to pick up change to admin password"
service httpd restart
