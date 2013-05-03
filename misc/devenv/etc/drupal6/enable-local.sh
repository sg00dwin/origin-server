#!/bin/bash

echo "Enabling Drupal to use local assets"
pushd /etc/drupal6/default/
sed -e "s/\(\/\/\)?\(\$conf\['openshift_assets_url'\]\).*/\1 = 'http:\/\/localhost:3000\/assets';/" /etc/drupal6/default/redhat_settings.php
service httpd restart
popd
