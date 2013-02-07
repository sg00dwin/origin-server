#!/bin/bash

echo "Disabling SSO for Broker..."
sed -i 's/\INTEGRATED_AUTH=\"true\"/INTEGRATED_AUTH="false"/' /etc/openshift/plugins.d/openshift-origin-auth-streamline-dev.conf
service rhc-broker restart

echo "Disabling SSO for Site..."
sed -i "s/config\.integrated \= true/config.integrated = false/" /var/www/openshift/site/config/environments/development.rb
service rhc-site restart

echo "Disabling SSO for Drupal..."
pushd /etc/drupal6/default/
cp redhat_settings.php.orig redhat_settings.php
chown .libra_user redhat_settings.php
popd
