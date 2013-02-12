#!/bin/bash

echo "Enabling SSO for Broker..."
sed -i 's/\INTEGRATED_AUTH=\"false\"/INTEGRATED_AUTH="true"/' /etc/openshift/plugins.d/openshift-origin-auth-streamline-dev.conf
service rhc-broker restart

echo "Enabling SSO for Site..."
sed -i "s/config\.integrated\ \=\ false/config.integrated\ =\ true/" /var/www/openshift/site/config/environments/development.rb
service rhc-site restart

echo "Enabling SSO for Drupal..."
pushd /etc/drupal6/default/
sed -i "s/redhat_sso_skip_password'\]\ \=\ true/redhat_sso_skip_password'\]\ \=\ false/" /etc/drupal6/default/redhat_settings.php
service httpd restart
popd

echo "Note: You can configure both Drupal and the site to use redhat.com domain to set cookies by editing the cookie_domain variable in redhat_settings.php and streamline :cookie_domain => nil in site development.rb, then restarting the services."
