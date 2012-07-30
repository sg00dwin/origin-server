#!/bin/bash

echo "Dropping database and recreating"
mysql -e 'drop database libra;'
zcat /usr/share/drupal6/sites/default/openshift-dump.gz | mysql -u root
