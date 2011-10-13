echo "nameserver 4.2.2.2" >> /etc/resolv.conf

rpm -Uhv http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
rpm -e rh-amazon-rhui-client
rpm -Uhv http://209.132.178.9/gpxe/trees/li/rhel/6/x86_64/rhel6-and-optional-0.1-1.noarch.rpm

sed -i s/sslverify=1/sslverify=0/g /etc/yum.repos.d/rh-cloud.repo

wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

cat > /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - \$basearch
baseurl=http://209.132.178.9/gpxe/trees/libra-rhel-6.1-${1-candidate}/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-beta
ggpkey=http://209.132.178.9/gpxe/trees/RPM-GPG-KEY-redhat-release

[li-source]
name=Li repo for Enterprise Linux 6 - Source
baseurl=http://209.132.178.9/gpxe/trees/libra-rhel-6.1-${1-candidate}/source/SRPMS/
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
