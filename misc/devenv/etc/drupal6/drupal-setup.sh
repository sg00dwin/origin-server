#!/bin/bash

#Setup the administrative password to the default
drush user-password admin --password="admin"

#Enable the garland theme for use by the admin
drush en garland

#Enable markdown (bug in export?)
drush en markdown

#Ensure there is a sample test user
drush user-create test --mail="test@test.com" --password="test"

