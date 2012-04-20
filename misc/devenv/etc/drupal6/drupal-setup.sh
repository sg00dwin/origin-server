#!/bin/bash

#Setup the administrative password to the default
drush user-password admin --password="admin"

#Ensure there is a sample test user
drush user-create test --mail="test@test.com" --password="test"

