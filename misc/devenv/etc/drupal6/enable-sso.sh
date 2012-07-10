#!/bin/bash

echo "Enabling SSO for Broker..."
sed -i 's/\:integrated => false/:integrated => true/' /var/www/stickshift/broker/config/environments/development.rb
service libra-broker restart

echo "Enabling SSO for Site..."
sed -i "s/config\.integrated\ \=\ false/config.integrated\ =\ true/" /var/www/stickshift/site/config/environments/development.rb
service libra-site restart

echo "Enabling SSO for Drupal..."
pushd /etc/drupal6/default/
mv redhat_settings.php redhat_settings.php.orig
cp redhat_settings_staging.php redhat_settings.php
chown .libra_user redhat_settings.php
popd
echo "Note: You can configure both Drupal and the site to use EC2 domain to set cookies by changing $$cookie_domain and streamline :cookie_domain => :current"
