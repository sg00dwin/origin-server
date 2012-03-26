#!/bin/bash

echo "Enabling SSO for Broker..."
pushd /var/www/stickshift/broker/config/environments/
mv development.rb development.rb.orig
cp streamline-aws.rb development.rb
service libra-broker restart
popd
echo "Enabling SSO for Site..."
pushd /var/www/stickshift/site/config/environments/
mv development.rb development.rb.orig
cp streamline-aws.rb development.rb
service libra-site restart
popd
