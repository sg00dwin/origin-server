#!/bin/bash -x

control_c()
{
  echo -en "\n*** Exiting ***\n"
  exit $?
}
 
# trap keyboard interrupt (control-c)
trap control_c SIGINT

repodir=/build
prod_build=1
build_only=0
mkdir -p ${repodir}/brew ${repodir}/tito
cd ${repodir}

cd ${repodir}/li
find * | grep "\._" | xargs rm -f

cd ${repodir}/crankcase
find * | grep "\._" | xargs rm -f

if [ "x${prod_build}x" == "x0x" ] ; then
  test_build=" --test --rpm ";
else
  test_build=" --srpm"
fi

rm -rf ${repodir}/tito/*
cd ${repodir}/os-client-tools/rhc-rest
tito build $test_build --srpm --output=${repodir}/tito

cd ${repodir}/os-client-tools/express
tito build $test_build --srpm --output=${repodir}/tito

cd ${repodir}/crankcase/stickshift
for i in `ls`; do cd $i && tito build $test_build --output=${repodir}/tito ; cd - ; done

cd ${repodir}/crankcase/uplift/bind        && tito build $test_build --output=${repodir}/tito ; cd -
cd ${repodir}/crankcase/swingshift/mongo   && tito build $test_build --output=${repodir}/tito ; cd -
cd ${repodir}/crankcase/gearchanger/oddjob && tito build $test_build --output=${repodir}/tito ; cd -
cd ${repodir}/crankcase/crankcase/mongo    && tito build $test_build --output=${repodir}/tito ; cd -

cd ${repodir}/crankcase/cartridges
for i in 10gen-mms-agent-0.1 cron-1.4 diy-0.1 jbossas-7 jbosseap-6.0 jenkins-1.4 jenkins-client-1.4 mongodb-2.0 mysql-5.1 nodejs-0.6 perl-5.10 php-5.3 phpmyadmin-3.4 python-2.6 ruby-1.8 ; do 
  cd ${repodir}/crankcase/cartridges/$i; 
  tito build $test_build --output=${repodir}/tito;
done

sudo bash -c "cat <<EOF > /etc/yum.repos.d/ss.repo
[SS]
name = ss
baseurl = file://${repodir}/tito/rpms/fc16/x86_64
gpgcheck=0
enabled = 1

[SSBrew]
name = ssb
baseurl = file://${repodir}/brew
enabled = 1
gpgcheck=0
EOF"

if [ "x${prod_build}x" == "x1x" ] ; then
  rm -f ${repodir}/tito/*.tar.gz
  sudo setenforce 0
  mock -r fedora-16-x86_64 --resultdir=${repodir}/tito/rpms/"%(dist)s"/"%(target_arch)s"/ ${repodir}/tito/*.src.rpm
  sudo setenforce 1
else
  mkdir -p ${repodir}/tito/rpms/fc16/x86_64/
  cp ${repodir}/tito/noarch/*.rpm ${repodir}/tito/rpms/fc16/x86_64/
fi

createrepo ${repodir}/tito/rpms/fc16/x86_64

if [ "x${build_only}x" == "x1x" ] ; then
  exit 0;
fi

sudo yum remove -y stickshift-* rubygem-stickshift* cartridge-*
sudo rm -rf /usr/libexec/stickshift/cartridges/* /var/www/stickshift/broker/*
sudo yum -y --skip-broken install ${repodir}/tito/rpms/fc16/x86_64/rhc-*.rpm              ${repodir}/tito/rpms/fc16/x86_64/rubygem-*.rpm \
                                  ${repodir}/tito/rpms/fc16/x86_64/stickshift-broker*.rpm ${repodir}/tito/rpms/fc16/x86_64/stickshift-abstract*.rpm \
                                  ${repodir}/tito/rpms/fc16/x86_64/cartridge-*            ${repodir}/brew/jenkins-plugin-openshift-*.rpm 

echo "setup bind-plugin selinux policy"
sudo mkdir -p /usr/share/selinux/packages/rubygem-uplift-bind-plugin
sudo cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhcpnamedforward.* /usr/share/selinux/packages/rubygem-uplift-bind-plugin/
pushd /usr/share/selinux/packages/rubygem-uplift-bind-plugin/ && sudo make -f /usr/share/selinux/devel/Makefile ; popd
sudo semodule -i /usr/share/selinux/packages/rubygem-uplift-bind-plugin/dhcpnamedforward.pp

sudo sed -i -e "s/^# Add plugin gems here/# Add plugin gems here\ngem 'swingshift-mongo-plugin'\ngem 'uplift-bind-plugin'\ngem 'gearchanger-oddjob-plugin'\n/" /var/www/stickshift/broker/Gemfile
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
KEY=$( sudo bash -c "grep Key: /var/named/Kexample.com.*.private" | cut -d' ' -f 2 )
sudo bash -c "echo \"require File.expand_path('../plugin-config/uplift-bind-plugin.rb', __FILE__)\" >> /var/www/stickshift/broker/config/environments/development.rb"
sudo bash -c "cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/uplift-bind-plugin.rb
Broker::Application.configure do
  config.dns = {
    :server => '127.0.0.1',
    :port => 53,
    :keyname => 'example.com',
    :keyvalue => '${KEY}',
    :zone => 'example.com'
  }
end
EOF"


sudo chkconfig stickshift-broker on
sudo service stickshift-broker restart
sudo service httpd restart
sudo service dbus restart
sudo service oddjobd restart
