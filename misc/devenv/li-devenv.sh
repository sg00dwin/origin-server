#!/bin/bash

#rpm -Uhv http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
#rpm -Uhv http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
baseurl=http://mirror1.ops.rhcloud.com/mirror/epel/6/\$basearch/
        http://mirror2.ops.rhcloud.com/mirror/epel/6/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0

[epel-testing]
name=Extra Packages for Enterprise Linux 6 - Testing - \$basearch
baseurl=http://mirror1.ops.rhcloud.com/mirror/epel/testing/6/\$basearch/
        http://mirror2.ops.rhcloud.com/mirror/epel/testing/6/\$basearch/
failovermethod=priority
enabled=0
gpgcheck=0

EOF
#sed -i s/sslverify=1/sslverify=0/g /etc/yum.repos.d/rh-cloud.repo

cat > /etc/yum.repos.d/li.repo <<EOF
[qpid]
name=Qpid repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.ops.rhcloud.com/libra/qpid/\$basearch/Packages/
        https://mirror2.ops.rhcloud.com/libra/qpid/\$basearch/Packages/
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=https://mirror1.ops.rhcloud.com/libra/li-signing.asc
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[passenger]
name=Passenger repo for Enterprise Linux 6
baseurl=https://mirror1.ops.rhcloud.com/libra/passenger
        https://mirror2.ops.rhcloud.com/libra/passenger
failovermethod=priority
enabled=1
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[rhui-us-east-1-rhel-server-releases-i386]
name=Red Hat Enterprise Linux Server 6 -i386 (RPMs)
mirrorlist=https://rhui2-cds01.us-east-1.aws.ce.redhat.com/pulp/mirror/content/dist/rhel/rhui/server/6/\$releasever/i386/os
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-auxiliary
sslverify=1
sslclientkey=/etc/pki/entitlement/content-rhel6.key
sslclientcert=/etc/pki/entitlement/product/content-rhel6.crt
sslcacert=/etc/pki/entitlement/cdn.redhat.com-chain.crt
includepkgs=java-1.6.0-openjdk* java-1.7.0-openjdk*

[rhui-us-east-1-rhel-server-releases-optional-i386]
name=Red Hat Enterprise Linux Server 6 Optional -i386 (RPMs)
mirrorlist=https://rhui2-cds01.us-east-1.aws.ce.redhat.com/pulp/mirror/content/dist/rhel/rhui/server/6/\$releasever/i386/optional/os
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-auxiliary
sslverify=1
sslclientkey=/etc/pki/entitlement/content-rhel6.key
sslclientcert=/etc/pki/entitlement/product/content-rhel6.crt
sslcacert=/etc/pki/entitlement/cdn.redhat.com-chain.crt
includepkgs=java-1.6.0-openjdk* java-1.7.0-openjdk*

[Zend]
name=Zend Server
baseurl=http://mirror2.ops.rhcloud.com/mirror/zend/$basearch
        http://mirror1.ops.rhcloud.com/mirror/zend/$basearch
enabled=1
gpgcheck=0

[Zend_noarch]
name=Zend Server - noarch
baseurl=http://mirror2.ops.rhcloud.com/mirror/zend/noarch
        http://mirror1.ops.rhcloud.com/mirror/zend/noarch
enabled=1
gpgcheck=0

EOF

if [[ "$1" == "test" ]]; then

cat >> /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.ops.rhcloud.com/libra/libra-rhel-6.3-test/\$basearch/
        https://mirror2.ops.rhcloud.com/libra/libra-rhel-6.3-test/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[li-source]
name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.ops.rhcloud.com/libra/libra-rhel-6.3-test/source/SRPMS/
        https://mirror2.ops.rhcloud.com/libra/libra-rhel-6.3-test/source/SRPMS/
failovermethod=priority
enabled=0
gpgkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem
EOF

else

cat >> /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.ops.rhcloud.com/libra/libra-rhel-6.3-${1-candidate}/\$basearch/
        https://mirror2.ops.rhcloud.com/libra/libra-rhel-6.3-${1-candidate}/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem

[li-source]

name=Li repo for Enterprise Linux 6 - $basearch
baseurl=https://mirror1.ops.rhcloud.com/libra/libra-rhel-6.3-${1-candidate}/source/SRPMS/
        https://mirror2.ops.rhcloud.com/libra/libra-rhel-6.3-${1-candidate}/source/SRPMS/
failovermethod=priority
enabled=0
gpgkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-beta
ggpkey=https://mirror1.ops.rhcloud.com/libra/RPM-GPG-KEY-redhat-release
gpgcheck=0
sslverify=0
sslclientcert=/var/lib/yum/client-cert.pem
sslclientkey=/var/lib/yum/client-key.pem
EOF

fi

# Enable RHUI JBoss repos for cartridge rebase on core EAP packages and enable RHUI JB EWS repos for Tomcat cartridge
yum -y install rh-amazon-rhui-client-jbeap6 rh-amazon-rhui-client-jbews1

# Install the 32 bit java before anything else
yum -y install java-1.6.0-openjdk.i686 java-1.6.0-openjdk-devel.i686
yum -y remove java-1.6.0-openjdk.x86_64
rpm -e --nodeps java-1.7.0-openjdk java-1.7.0-openjdk-devel
yum -y install java-1.7.0-openjdk.i686 java-1.7.0-openjdk-devel.i686

