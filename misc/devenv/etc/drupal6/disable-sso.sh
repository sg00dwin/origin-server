#!/bin/bash

echo "Disabling SSO for Broker..."
sed -i 's/\:integrated => true/:integrated => false/' /var/www/stickshift/broker/config/environments/development.rb
service libra-broker restart

echo "Disabling SSO for Site..."
sed -i "s/config\.integrated \= true/config.integrated = false/" /var/www/stickshift/site/config/environments/development.rb
service libra-site restart

echo "Disabling SSO for Drupal..."
pushd /etc/drupal6/default/
cp redhat_settings.php.orig redhat_settings.php
chown .libra_user redhat_settings.php
popd
