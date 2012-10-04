#!/bin/bash

echo "Enabling SSO for Broker..."
sed -i 's/\:integrated => false/:integrated => true/' /var/www/openshift/broker/config/environments/development.rb
service rhc-broker restart

echo "Enabling SSO for Site..."
sed -i "s/config\.integrated\ \=\ false/config.integrated\ =\ true/" /var/www/openshift/site/config/environments/development.rb
service rhc-site restart

echo "Enabling SSO for Drupal..."
pushd /etc/drupal6/default/
mv redhat_settings.php redhat_settings.php.orig
cp redhat_settings_staging.php redhat_settings.php
chown .libra_user redhat_settings.php
popd
echo "Note: You can configure both Drupal and the site to use redhat.com domain to set cookies by editing the cookie_domain variable in redhat_settings.php and streamline :cookie_domain => nil in site development.rb, then restarting the services."
