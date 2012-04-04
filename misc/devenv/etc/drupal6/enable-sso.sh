#!/bin/bash

echo "Enabling SSO for Broker..."
pushd /var/www/stickshift/broker/config/environments/
mv development.rb development.rb.orig
cp streamline-aws.rb development.rb
chown .libra_user development.rb
service libra-broker restart
popd
echo "Enabling SSO for Site..."
pushd /var/www/stickshift/site/config/environments/
mv development.rb development.rb.orig
cp streamline-aws.rb development.rb
chown .libra_user development.rb
service libra-site restart
popd
echo "Enabling SSO for Drupal..."
pushd /etc/drupal6/default/
mv redhat_settings.php redhat_settings.php.orig
cp redhat_settings_staging.php redhat_settings.php
chown .libra_user redhat_settings.php
popd
echo "Note: You can configure both Drupal and the site to use EC2 domain to set cookies by changing $$cookie_domain and streamline :cookie_domain => :current"
