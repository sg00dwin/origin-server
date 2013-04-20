#!/bin/bash

echo "Disabling SSO for Broker..."
sed -i 's/\INTEGRATED_AUTH=\"true\"/INTEGRATED_AUTH="false"/' /etc/openshift/plugins.d/openshift-origin-auth-streamline-dev.conf
service rhc-broker restart

echo "Disabling SSO for Site..."
sed -i "s/STREAMLINE_ENABLED=true/STREAMLINE_ENABLED=false/" /etc/openshift/console-devenv.conf
service rhc-site restart

echo "Disabling SSO for Drupal..."
pushd /etc/drupal6/default/
sed -i "s/redhat_sso_skip_password'\]\ \=\ false/redhat_sso_skip_password'\]\ \=\ true/" /etc/drupal6/default/redhat_settings.php
service httpd restart
popd
