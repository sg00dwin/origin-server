#!/bin/bash

repodir="~"

sudo yum remove -y stickshift-* rubygem-stickshift* cartridge-*
rm -rf /usr/libexec/stickshift/cartridges/* /var/www/stickshift/broker/*
cd ${repodir}/

cd ${repodir}/li
find * | grep "\._" | xargs rm -f
rm -rf /tmp/tito/*

cd ${repodir}/os-client-tools/express
tito build --test --srpm --output=$HOME/tito

cd ~/li
find * | grep "\._" | xargs rm -f

rm -rf ~/tito/*
cd ~/li/stickshift
for i in `ls`; do cd $i && sudo tito build --test --srpm --output=$HOME/tito ; cd - ; done

cd ~/li/uplift/bind        && sudo tito build --test --srpm --output=$HOME/tito ; cd -
cd ~/li/swingshift/mongo   && sudo tito build --test --srpm --output=$HOME/tito ; cd -
cd ~/li/gearchanger/oddjob && sudo tito build --test --srpm --output=$HOME/tito ; cd -
cd ~/li/crankcase/mongo    && sudo tito build --test --srpm --output=$HOME/tito ; cd -

cd ~/li/cartridges
for i in 10gen-mms-agent-0.1 cron-1.4 diy-0.1 jbossas-7 jenkins-1.4 jenkins-client-1.4 mongodb-2.0 mysql-5.1 nodejs-0.6 perl-5.10 php-5.3 phpmyadmin-3.4 python-3.2 ruby-1.1 ; do cd ~/li/cartridges/$i ; sudo tito build --test --srpm --output=$HOME/tito ; done

rm -f ~/tito/*.tar.gz
mock -r fedora-16-x86_64 --resultdir=$HOME/tito/rpms/"%(dist)s"/"%(target_arch)s"/ ~/tito/*.src.rpm
createrepo $HOME/tito/rpms/fc16/x86_64

sudo yum -y --skip-broken install //home/kraman/tito/rpms/fc16/x86_64/rhc-*.rpm  //home/kraman/tito/rpms/fc16/x86_64/rubygem-*.rpm //home/kraman/tito/rpms/fc16/x86_64/stickshift-broker*.rpm //home/kraman/tito/rpms/fc16/x86_64/stickshift-abstract*.rpm //home/kraman/tito/rpms/fc16/x86_64/cartridge-* ${repodir}/brew/jenkins-plugin-openshift-*.rpm 

echo "setup bind-plugin selinux policy"
sudo mkdir -p /usr/share/selinux/packages/rubygem-uplift-bind-plugin
sudo cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhcpnamedforward.* /usr/share/selinux/packages/rubygem-uplift-bind-plugin/
pushd /usr/share/selinux/packages/rubygem-uplift-bind-plugin/ && sudo make -f /usr/share/selinux/devel/Makefile ; popd
sudo semodule -i /usr/share/selinux/packages/rubygem-uplift-bind-plugin/dhcpnamedforward.pp

sudo sed -i -e "s/^# Add plugin gems here/# Add plugin gems here\ngem 'swingshift-mongo-plugin'\ngem 'uplift-bind-plugin'\ngem 'crankcase-mongo-plugin'\ngem 'gearchanger-oddjob-plugin'\n/" /var/www/stickshift/broker/Gemfile
sudo bash -c "cd /var/www/stickshift/broker/ && rm -f Gemfile.lock && bundle show && chown apache:apache Gemfile.lock"

sudo mkdir -p /var/www/stickshift/broker/config/environments/plugin-config

sudo bash -c "echo \"require File.expand_path('../plugin-config/swingshift-mongo-plugin.rb', __FILE__)\" >> /var/www/stickshift/broker/config/environments/development.rb"
sudo bash -c 'cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/swingshift-mongo-plugin.rb
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
EOF'

sudo cp -n /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/Kexample.com.* /var/named
KEY=$( grep Key: /var/named/Kexample.com.*.private | cut -d' ' -f 2 )
sudo bash -c "echo \"require File.expand_path('../plugin-config/uplift-bind-plugin.rb', __FILE__)\" >> /var/www/stickshift/broker/config/environments/development.rb"
sudo bash -c 'cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/uplift-bind-plugin.rb
Broker::Application.configure do
  config.dns = {
    :server => "127.0.0.1",
    :port => 53,
    :keyname => "example.com",
    :keyvalue => "${KEY}",
    :zone => "example.com"
  }
end
EOF'

sudo bash -c "echo \"require File.expand_path('../plugin-config/crankcase-mongo-plugin.rb', __FILE__)\" >> /var/www/stickshift/broker/config/environments/development.rb"
sudo bash -c 'cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/crankcase-mongo-plugin.rb
Broker::Application.configure do
  config.datastore = {
    :replica_set => false,
    # Replica set example: [[<host-1>, <port-1>], [<host-2>, <port-2>], ...]
    :host_port => ["localhost", 27017],

    :user => "stickshift",
    :password => "mooo",
    :db => "stickshift_broker_dev",
    :collections => {:user => "user"}
  }
end
EOF'

sudo chkconfig stickshift-broker on
sudo service stickshift-broker restart
sudo service httpd restart
sudo service dbus restart
sudo service oddjobd restart
