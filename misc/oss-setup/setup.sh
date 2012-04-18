#!/bin/bash

repodir="~"

yum install -y vim git wget tito ruby rubygems java-1.6.0-openjdk jpackage-utils java-1.6.0-openjdk-devel emacs fedora-kickstarts livecd-tools tig

if [ ! -d ${repodir}/li ]; then
  git clone git:/srv/git/li.git ${repodir}/li
else
  pushd ${repodir}/li
  git stash
  git pull --rebase
  git stash pop
  popd
fi

if [ ! -d ${repodir}/jenkins-cloud ]; then
  git clone git:/srv/git/jenkins-cloud.git ${repodir}/jenkins-cloud
fi

if [ ! -d ${repodir}/os-client-tools ]; then
  git clone git://github.com/openshift/os-client-tools.git ${repodir}/os-client-tools
fi

mkdir -p ${repodir}/brew
mkdir -p /tmp/tito
pushd ${repodir}/brew

FOO=`yum search 'rubygem-mongo' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading rubygem(bson) from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=194826]"
  wget -O ${repodir}/brew/rubygem-bson-1.5.2-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/rubygem-bson/1.5.2/1.el6_2/noarch/rubygem-bson-1.5.2-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/rubygem-bson-1.5.2-1.el6_2.noarch.rpm

  echo "Downloading rubygem(mongo) from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=194827]"
  wget -O ${repodir}/brew/rubygem-mongo-1.5.2-2.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/rubygem-mongo/1.5.2/2.el6_2/noarch/rubygem-mongo-1.5.2-2.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/rubygem-mongo-1.5.2-2.el6_2.noarch.rpm
fi

FOO=`yum search 'rubygem-bson_ext' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading rubygem(bson_ext) from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=196476]"
  wget -O ${repodir}/brew/rubygem-bson_ext-1.5.2-1.el6_2.x86_64.rpm http://download.devel.redhat.com/brewroot/packages/rubygem-bson_ext/1.5.2/1.el6_2/x86_64/rubygem-bson_ext-1.5.2-1.el6_2.x86_64.rpm
  yum install -y ${repodir}/brew/rubygem-bson_ext-1.5.2-1.el6_2.x86_64.rpm
fi

FOO=`yum search 'rubygem-thread-dump' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading rubygem(thread-dump) from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=196395]"
  wget -O ${repodir}/brew/rubygem-thread-dump-0.0.5-88.noarch.rpm http://download.devel.redhat.com/brewroot/packages/rubygem-thread-dump/0.0.5/88/noarch/rubygem-thread-dump-0.0.5-88.noarch.rpm
  yum install -y ${repodir}/brew/rubygem-thread-dump-0.0.5-88.noarch.rpm
fi

FOO=`yum search 'jboss-as7' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading jboss-as7 from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=200847]"
  wget -O ${repodir}/brew/jboss-as7-7.1.0.Final-5.noarch.rpm http://download.devel.redhat.com/brewroot/packages/jboss-as7/7.1.0.Final/5/noarch/jboss-as7-7.1.0.Final-5.noarch.rpm
  yum install -y ${repodir}/brew/jboss-as7-7.1.0.Final-5.noarch.rpm
fi

FOO=`yum search 'jboss-as7-modules' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading jboss-as7-modules from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=200849]"
  wget -O ${repodir}/brew/jboss-as7-modules-7.1.0.Final-2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/jboss-as7-modules/7.1.0.Final/2/noarch/jboss-as7-modules-7.1.0.Final-2.noarch.rpm
  yum install -y ${repodir}/brew/jboss-as7-modules-7.1.0.Final-2.noarch.rpm
fi

FOO=`yum search 'nodejs' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=200892]"
  wget -O ${repodir}/brew/nodejs-0.6.11-1.el6_2.x86_64.rpm http://download.devel.redhat.com/brewroot/packages/nodejs/0.6.11/1.el6_2/x86_64/nodejs-0.6.11-1.el6_2.x86_64.rpm
  yum install -y ${repodir}/brew/nodejs-0.6.11-1.el6_2.x86_64.rpm
fi

FOO=`yum search 'nodejs-node-static' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-node-static from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199176]"
  wget -O ${repodir}/brew/nodejs-node-static-0.5.9-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-node-static/0.5.9/1.el6_2/noarch/nodejs-node-static-0.5.9-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-node-static-0.5.9-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-async' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-async from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199174]"
  wget -O ${repodir}/brew/nodejs-async-0.1.16-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-async/0.1.16/1.el6_2/noarch/nodejs-async-0.1.16-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-async-0.1.16-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-traverse' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-traverse from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199042]"
  wget -O ${repodir}/brew/nodejs-traverse-0.5.2-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-traverse/0.5.2/1.el6_2/noarch/nodejs-traverse-0.5.2-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-traverse-0.5.2-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-hashish' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-hashish from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199245]"
  wget -O ${repodir}/brew/nodejs-hashish-0.0.4-2.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-hashish/0.0.4/2.el6_2/noarch/nodejs-hashish-0.0.4-2.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-hashish-0.0.4-2.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-mysql' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-mysql from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199238]"
  wget -O ${repodir}/brew/nodejs-mysql-0.9.5-2.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-mysql/0.9.5/2.el6_2/noarch/nodejs-mysql-0.9.5-2.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-mysql-0.9.5-2.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-mongodb' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-mongodb from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199036]"
  wget -O ${repodir}/brew/nodejs-mongodb-0.9.9.1-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-mongodb/0.9.9.1/1.el6_2/noarch/nodejs-mongodb-0.9.9.1-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-mongodb-0.9.9.1-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-generic-pool' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-generic-pool from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199034]"
  wget -O ${repodir}/brew/nodejs-generic-pool-1.0.9-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-generic-pool/1.0.9/1.el6_2/noarch/nodejs-generic-pool-1.0.9-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-generic-pool-1.0.9-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-pg' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-pg from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199041]"
  wget -O ${repodir}/brew/nodejs-pg-0.6.10-1.el6_2.x86_64.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-pg/0.6.10/1.el6_2/x86_64/nodejs-pg-0.6.10-1.el6_2.x86_64.rpm
  yum install -y ${repodir}/brew/nodejs-pg-0.6.10-1.el6_2.x86_64.rpm
fi

FOO=`yum search 'nodejs-qs' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-qs from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199179]"
  wget -O ${repodir}/brew/nodejs-qs-0.4.2-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-qs/0.4.2/1.el6_2/noarch/nodejs-qs-0.4.2-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-qs-0.4.2-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-mime' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-mime from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199175]"
  wget -O ${repodir}/brew/nodejs-mime-1.2.5-1.el6_2.noarch.rpm  http://download.devel.redhat.com/brewroot/packages/nodejs-mime/1.2.5/1.el6_2/noarch/nodejs-mime-1.2.5-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-mime-1.2.5-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-formidable' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-formidable from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199177]"
  wget -O ${repodir}/brew/nodejs-formidable-1.0.9-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-formidable/1.0.9/1.el6_2/noarch/nodejs-formidable-1.0.9-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-formidable-1.0.9-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-mkdirp' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-mkdirp from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=200894]"
  wget -O ${repodir}/brew/nodejs-mkdirp-0.3.0-2.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-mkdirp/0.3.0/2.el6_2/noarch/nodejs-mkdirp-0.3.0-2.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-mkdirp-0.3.0-2.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-connect' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-connect from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199172]"
  wget -O ${repodir}/brew/nodejs-connect-1.8.5-1.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-connect/1.8.5/1.el6_2/noarch/nodejs-connect-1.8.5-1.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-connect-1.8.5-1.el6_2.noarch.rpm
fi

FOO=`yum search 'nodejs-express' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading nodejs-express from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=199239]"
  wget -O ${repodir}/brew/nodejs-express-2.5.8-2.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/nodejs-express/2.5.8/2.el6_2/noarch/nodejs-express-2.5.8-2.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/nodejs-express-2.5.8-2.el6_2.noarch.rpm
fi

FOO=`yum search 'mms-agent' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  echo "Downloading mms-agent from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=192484]"
  wget -O ${repodir}/brew/mms-agent-1.3.7-3.el6_2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/mms-agent/1.3.7/3.el6_2/noarch/mms-agent-1.3.7-3.el6_2.noarch.rpm
  yum install -y ${repodir}/brew/mms-agent-1.3.7-3.el6_2.noarch.rpm
fi

if [ ! -e ${repodir}/brew/jenkins-1.409.3-1.2.noarch.rpm ] ; then
  echo "Downloading jenkins from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=186859]"
  wget -O ${repodir}/brew/jenkins-1.409.3-1.2.noarch.rpm http://download.devel.redhat.com/brewroot/packages/jenkins/1.409.3/1.2/noarch/jenkins-1.409.3-1.2.noarch.rpm
  yum install -y ${repodir}/brew/jenkins-1.409.3-1.2.noarch.rpm
fi

if [ ! -e ${repodir}/brew/jenkins-plugin-openshift-0.5.13-0.el6_2.x86_64.rpm ] ; then
  echo "Downloading jenkins-plugin-openshift from BREW [https://brewweb.devel.redhat.com/buildinfo?buildID=209034]"
  wget -O ${repodir}/brew/jenkins-plugin-openshift-0.5.13-0.el6_2.x86_64.rpm http://download.devel.redhat.com/brewroot/packages/jenkins-plugin-openshift/0.5.13/0.el6_2/x86_64/jenkins-plugin-openshift-0.5.13-0.el6_2.x86_64.rpm
fi

FOO=`yum search 'mod_passenger' 2>&1 | grep "No match"`
if [ "xx" != "x${FOO}x" ] ; then
  rpm --import http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc
  yum install -y http://passenger.stealthymonkeys.com/fedora/16/passenger-release.noarch.rpm
  yum install -y mod_passenger
fi

popd

chkconfig sshd on
service sshd start
lokkit --service=ssh

yum remove -y stickshift-* rubygem-stickshift* cartridge-*
rm -rf /usr/libexec/stickshift /var/lib/stickshift /var/www/stickshift /etc/stickshift /usr/share/selinux/packages/rubygem-gearchanger-oddjob-plugin /usr/share/selinux/packages/rubygem-uplift-bind-plugin /usr/share/selinux/packages/stickshift-broker
semodule -r gearchanger-oddjob dhcpnamedforward stickshift-broker

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Move ephemeral port range to accommodate app proxies
echo "net.ipv4.ip_local_port_range = 15000 35530" >> /etc/sysctl.conf
sysctl net.ipv4.ip_local_port_range="15000 35530"

# Increase the connection tracking table size
echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.conf
sysctl net.netfilter.nf_conntrack_max=1048576

# Setup swap for devenv
[ -f /.swap ] || ( /bin/dd if=/dev/zero of=/.swap bs=1024 count=1024000
    /sbin/mkswap -f /.swap
    /sbin/swapon /.swap
    echo "/.swap swap   swap    defaults        0 0" >> /etc/fstab
)

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

yum install -y mongodb mongodb-server
perl -p -i -e "s/^#auth = .*$/auth = true/" /etc/mongodb.conf
chkconfig mongod on
service mongod start

#wait for "[initandlisten] waiting for connections"
WAIT=1
while [ 1 -eq $WAIT ] ; do fgrep "[initandlisten] waiting for connections" /var/log/mongodb/mongodb.log && WAIT=$? ; echo $WAIT ; sleep 1 ; done
mongo localhost/stickshift_broker_dev --eval "db.addUser(\"stickshift\", \"mooo\")"

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
${DIR}/build.sh

#setup uplift-bind-plugin selinux policy
mkdir -p /usr/share/selinux/packages/rubygem-uplift-bind-plugin
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhcpnamedforward.* /usr/share/selinux/packages/rubygem-uplift-bind-plugin/
pushd /usr/share/selinux/packages/rubygem-uplift-bind-plugin/ && make -f /usr/share/selinux/devel/Makefile ; popd
semodule -i /usr/share/selinux/packages/rubygem-uplift-bind-plugin/dhcpnamedforward.pp

# preserve the existing named config
if [ ! -f /etc/named.conf.orig ]
then
  mv /etc/named.conf /etc/named.conf.orig
fi

# install the local server named
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/named.conf /etc/named.conf
chown root:named /etc/named.conf
chcon system_u:object_r:named_conf_t:s0 -v /etc/named.conf

# get the first resolver from /etc/resolv.conf
FORWARDER=`grep nameserver /etc/resolv.conf | head -1 | cut -d' ' -f2`

# insert localhost before the first nameserver line
sed -i -e '1,/nameserver/ { /nameserver/ i\
nameserver 127.0.0.1
}' /etc/resolv.conf

# Set up the initial forwarder
echo "forwarders { ${FORWARDER} ; } ;" > /var/named/forwarders.conf

# set SELinux label for forwarders file
restorecon -v /var/named/forwarders.conf

# copy example.com. keys in place
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/Kexample.com.* /var/named
KEY=$( grep Key: /var/named/Kexample.com.*.private | cut -d' ' -f 2 )

cat <<EOF > /var/named/example.com.key
  key example.com {
    algorithm HMAC-MD5 ;
    secret "${KEY}" ;
  } ;
EOF
restorecon -v /var/named/example.com.key

cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/example.com.db /var/named/dynamic/
restorecon -v -R /var/named/dynamic/

chkconfig NetworkManager off
chkconfig network on
grep -l NM_CONTROLLED /etc/sysconfig/network-scripts/ifcfg-* | xargs perl -p -i -e '/NM_CONTROLLED/ && s/yes/no/i'

cat <<EOF > /etc/dhcp/dhclient.conf
# prepend localhost for DNS lookup in dev and test
prepend domain-name-servers 127.0.0.1 ;
EOF

cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhclient-up-hooks /etc/dhcp/dhclient-up-hooks

# Enable and start local named
chkconfig named on
service named start

#resource limits
cat <<EOF > /etc/stickshift/resource_limits.conf
#
# Apache bandwidth limit
# 
apache_bandwidth="all 500000"
apache_maxconnection="all 20"
apache_bandwidtherror="510"
#
# Apache rotatelogs tuning
rotatelogs_interval=86400
rotatelogs_format="-%Y%m%d-%H%M%S-%Z"
EOF

mkdir -p /tmp/tito/noarch /root/brew
createrepo /tmp/tito/noarch
createrepo /root/brew

cat <<EOF > /etc/yum.repos.d/ss.repo
[SS]
name = ss
baseurl = file:///tmp/tito/noarch
enabled = 1

[SSBrew]
name = ssb
baseurl = file:///root/brew
enabled = 1
EOF
