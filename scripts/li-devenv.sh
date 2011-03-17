rpm -Uhv http://download.fedora.redhat.com/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm
rpm -e rh-amazon-rhui-client
rpm -Uhv http://209.132.178.9/gpxe/trees/li/rhel/6/x86_64/rhel6-and-optional-0.1-1.noarch.rpm

cat > /etc/yum.repos.d/li.repo <<EOF
[li]
name=Li repo for Enterprise Linux 6 - \$basearch
baseurl=http://209.132.178.9/gpxe/trees/li-mash/\$basearch/
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=http://209.132.178.9/gpxe/trees/li/li-signing.asc

[li-source]
name=Li repo for Enterprise Linux 6 - Source
baseurl=http://209.132.178.9/gpxe/trees/li-mash/source/SRPMS/
failovermethod=priority
enabled=0
gpgkey=http://209.132.178.9/gpxe/trees/li/li-signing.asc
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

yum -y install li-devenv
