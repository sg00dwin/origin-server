echo "nameserver 4.2.2.2" >> /etc/resolv.conf

rpm -Uhv http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm

#sed -i s/sslverify=1/sslverify=0/g /etc/yum.repos.d/rh-cloud.repo

cat > /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - \$basearch
baseurl=http://209.132.178.9/gpxe/trees/libra-rhel-6.2-${1-candidate}/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-beta
ggpkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-release

[li-source]
name=Li repo for Enterprise Linux 6 - Source
baseurl=http://209.132.178.9/gpxe/trees/libra-rhel-6.2-${1-candidate}/source/SRPMS/
failovermethod=priority
enabled=0
gpgkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-beta
ggpkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-release
gpgcheck=0

[qpid]
name=Qpid repo
baseurl=http://209.132.178.9/gpxe/trees/qpid/\$basearch/Packages/
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=http://209.132.178.9/gpxe/trees/li/li-signing.asc

[passenger]
name=Passenger repo for Enterprise Linux 6
baseurl=http://209.132.178.9/gpxe/trees/passenger
failovermethod=priority
enabled=1
gpgcheck=0

EOF

yum -y install rhc-devenv
