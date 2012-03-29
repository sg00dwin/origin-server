#!/bin/bash

yum remove -y stickshift-* rubygem-stickshift* cartridge-*
rm -rf /usr/libexec/stickshift/cartridges/*
cd ~/

cd ~/li
find * | grep "\._" | xargs rm -f
rm -rf /tmp/tito/*

cd ~/os-client-tools/express
tito build --test --rpm > /dev/null

cd ~/li/stickshift
for i in `ls`; do cd $i && tito build --test --rpm >/dev/null ; cd - ; done

cd ~/li/uplift
for i in `ls`; do cd $i && tito build --test --rpm >/dev/null ; cd - ; done

cd ~/li/swingshift
for i in `ls`; do cd $i && tito build --test --rpm >/dev/null ; cd - ; done

cd ~/li/crankcase
for i in `ls`; do cd $i && tito build --test --rpm >/dev/null ; cd - ; done

cd ~/li/gearchanger
for i in `ls`; do cd $i && tito build --test --rpm >/dev/null ; cd - ; done

cd ~/li/cartridges
for i in `ls` ; do cd ~/li/cartridges/$i ; tito build --test --rpm >/dev/null ; done
createrepo /tmp/tito/noarch

yum -y --skip-broken install /tmp/tito/noarch/rhc-*.rpm  /tmp/tito/noarch/rubygem-*.rpm /tmp/tito/noarch/stickshift-broker*.rpm /tmp/tito/noarch/stickshift-abstract*.rpm /tmp/tito/noarch/cartridge-* ~/brew/jenkins-plugin-openshift-*.rpm 

sed -i -e "s/^# Add plugin gems here/# Add plugin gems here\ngem 'swingshift-mongo-plugin'\ngem 'uplift-bind-plugin'\ngem 'crankcase-mongo-plugin'\ngem 'gearchanger-oddjob-plugin'\n/" /var/www/stickshift/broker/Gemfile
pushd /var/www/stickshift/broker/ && rm -f Gemfile.lock && bundle show && chown apache:apache Gemfile.lock && popd

mkdir -p /var/www/stickshift/broker/config/environments/plugin-config

echo "require File.expand_path('../plugin-config/swingshift-mongo-plugin.rb', __FILE__)" >> /var/www/stickshift/broker/config/environments/development.rb
cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/swingshift-mongo-plugin.rb
Broker::Application.configure do
  config.auth = {
    :salt => "ClWqe5zKtEW4CJEMyjzQ",
    
    # Replica set example: [[<host-1>, <port-1>], [<host-2>, <port-2>], ...]
    :mongo_replica_sets => false,
    :mongo_host_port => ["localhost", 27017],
  
    :mongo_user => "stickshift",
    :mongo_password => "mooo",
    :mongo_db => "stickshift_broker_dev",
    :mongo_collection => "auth_user"
  }
end
EOF

cp -n /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/Kexample.com.* /var/named
KEY=$( grep Key: /var/named/Kexample.com.*.private | cut -d' ' -f 2 )
echo "require File.expand_path('../plugin-config/uplift-bind-plugin.rb', __FILE__)" >> /var/www/stickshift/broker/config/environments/development.rb
cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/uplift-bind-plugin.rb
Broker::Application.configure do
  config.dns = {
    :server => "127.0.0.1",
    :port => 53,
    :keyname => "example.com",
    :keyvalue => "${KEY}",
    :zone => "example.com"
  }
end
EOF

chkconfig stickshift-broker on
service stickshift-broker restart
service httpd restart
service dbus restart
service oddjobd restart
