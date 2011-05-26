%define libradir %{_sysconfdir}/libra/devenv

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.72.1
Release:   1%{?dist}
Group:     Development/Libraries
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-devenv-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc
Requires:  rhc-node
Requires:  rhc-node-tools
Requires:  rhc-site
Requires:  rhc-broker
Requires:  rhc-cartridge-php-5.3
Requires:  rhc-cartridge-wsgi-3.2
Requires:  rhc-cartridge-rack-1.1
Requires:  rhc-cartridge-jbossas-7.0
Requires:  qpid-cpp-server
Requires:  qpid-cpp-server-ssl
Requires:  puppet
Requires:  rubygem-cucumber
Requires:  rubygem-mocha
Requires:  rubygem-rspec
Requires:  rubygem-nokogiri

BuildArch: noarch

%description
Provides all the development dependencies to be able to run the OpenShift tests

%prep
%setup -q

%build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{libradir}
cp -adv devenv/* %{buildroot}%{libradir}

%clean
rm -rf %{buildroot}

%post

# ntp is not needed in para-virtualized systems
# the host maintains the clock
#service ntpd start
#chkconfig ntpd on

# qpid - configuring SSL
/bin/cp -rf %{libradir}/qpid/etc/* %{_sysconfdir}
/sbin/restorecon -R %{_sysconfdir}/qpid/pki
service qpidd restart
chkconfig qpidd on

# mcollective
/bin/cp -f %{libradir}/client.cfg %{libradir}/server.cfg /etc/mcollective
/bin/touch /tmp/mcollective-client.log
/bin/chmod 0666 /tmp/mcollective-client.log
service mcollective start
chkconfig mcollective on

# cggroups
chkconfig cgconfig on
service cgconfig start
chkconfig cgred on
service cgred start
service libra-cgroups start
service libra-tc start

# iptables
/bin/cp -f %{libradir}/iptables %{_sysconfdir}/sysconfig/iptables
%{_initddir}/iptables restart

# rails setup
ln -s /var/www/libra/site/public/* /var/www/html/.
/bin/touch %{_localstatedir}/www/libra/site/log/development.log
/bin/chmod 0666 %{_localstatedir}/www/libra/site/log/development.log
/bin/touch %{_localstatedir}/www/libra/broker/log/development.log
/bin/chmod 0666 %{_localstatedir}/www/libra/broker/log/development.log
/bin/mkdir -p /var/www/libra/site/httpd/logs
/bin/mkdir -p /var/www/libra/site/httpd/run
/bin/mkdir -p /var/www/libra/broker/httpd/logs
/bin/mkdir -p /var/www/libra/broker/httpd/run
/bin/ln -s /usr/lib64/httpd/modules/ /var/www/libra/site/httpd/modules
/bin/ln -s /usr/lib64/httpd/modules/ /var/www/libra/broker/httpd/modules
/bin/cp -f /etc/libra/devenv/httpd/000000_default.conf /etc/httpd/conf.d
/bin/cp -f /etc/libra/devenv/httpd/site.conf /var/www/libra/site/httpd
/bin/cp -f /etc/libra/devenv/httpd/httpd.conf /var/www/libra/site/httpd
/bin/cp -f /etc/libra/devenv/httpd/broker.conf /var/www/libra/broker/httpd
/bin/cp -f /etc/libra/devenv/httpd/httpd.conf /var/www/libra/broker/httpd
/bin/cp -f /etc/libra/devenv/libra-site /etc/init.d
/bin/cp -f /etc/libra/devenv/libra-broker /etc/init.d
/bin/cp -f /etc/libra/devenv/robots.txt /var/www/libra/site/public
/etc/init.d/libra-site restart
/etc/init.d/libra-broker restart
chkconfig libra-site on
chkconfig libra-broker on

# httpd
%{_initddir}/httpd restart
chkconfig httpd on

# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root /etc/libra/devenv/crontab

# Libra
/bin/cp -f /etc/libra/devenv/node.conf /etc/libra/devenv/controller.conf /etc/libra
/bin/cp -f /etc/libra/devenv/express.conf /etc/openshift

# Debugging utilities
/bin/cp -f /etc/libra/devenv/li-log-util /usr/bin/li-log-util

# enable disk quotas
/usr/bin/rhc-init-quota

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

%files
%defattr(-,root,root,-)
%{_sysconfdir}/libra/devenv/
