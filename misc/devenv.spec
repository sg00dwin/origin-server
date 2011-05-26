%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/libra
%define brokerdir %{_localstatedir}/www/libra/broker
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.72.1
Release:   2%{?dist}
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

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sysconfdir}
mkdir -p %{buildroot}%{_tmppath}
mkdir -p %{buildroot}%{libradir}
mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{sitedir}/log

# Move over all configs and scripts
cp -rf devenv/etc/* %{buildroot}%{_sysconfdir}
cp -rf devenv/bin/* %{buildroot}%{_bindir}

# Move over new http configurations
cp -rf devenv/httpd/* %{buildroot}%{libradir}
cp -rf devenv/httpd/httpd.conf %{buildroot}%{sitedir}
cp -rf devenv/httpd/httpd.conf %{buildroot}%{brokerdir}
ln -s %{sitedir}/public/* %{buildroot}%{htmldir}
ln -s %{_libdir}/httpd/modules/ %{buildroot}%{sitedir}/httpd/modules
ln -s %{_libdir}/httpd/modules/ %{buildroot}%{brokerdir}/httpd/modules

# Setup mcollective client log
touch %{buildroot}%{_tmppath}/mcollective-client.log

# Setup rails development logs
touch %{buildroot}%{brokerdir}/log/development.log
touch %{buildroot}%{sitedir}/log/development.log

%clean
rm -rf %{buildroot}

%post
# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root /etc/libra/devenv/crontab

# enable disk quotas
/usr/bin/rhc-init-quota

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

# Restore permissions
/sbin/restorecon -R %{_sysconfdir}/qpid/pki
/sbin/restorecon -R %{libradir}

# Start services
service iptables restart
service qpidd restart
service mcollective start
service libra-site restart
service libra-broker restart
service httpd restart
chkconfig iptables on
chkconfig qpidd on
chkconfig mcollective on
chkconfig libra-site on
chkconfig libra-broker on
chkconfig httpd on

# CGroup services
service cgconfig start
service cgred start
service libra-cgroups start
service libra-tc start
chkconfig cgconfig on
chkconfig cgred on
chkconfig libra-cgroups on
chkconfig libra-tc on

%files
%defattr(-,root,root,-)
%attr(0666,-,-) %{_tmppath}/mcollective-client.log
%attr(0666,-,-) %{brokerdir}/log/development.log
%attr(0666,-,-) %{sitedir}/log/development.log

%changelog
* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Spec cleanup
