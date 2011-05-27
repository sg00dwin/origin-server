%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/libra
%define brokerdir %{_localstatedir}/www/libra/broker
%define sitedir %{_localstatedir}/www/libra/site
%define devenvdir %{_sysconfdir}/libra/devenv

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.72.1
Release:   3%{?dist}
Group:     Development/Libraries
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-devenv-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc
Requires:  rhc-node
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

mkdir -p %{buildroot}%{devenvdir}
cp -adv * %{buildroot}%{devenvdir}

# Setup mcollective client log
mkdir -p %{buildroot}%{_tmppath}/log
touch %{buildroot}%{_tmppath}/mcollective-client.log

mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{sitedir}/log

# Setup rails development logs
touch %{buildroot}%{brokerdir}/log/development.log
touch %{buildroot}%{sitedir}/log/development.log

%clean
rm -rf %{buildroot}

%post

# Move over all configs and scripts
cp %{devenvdir}/init.d/* %{_initddir}
cp -rf %{devenvdir}/etc/* %{_sysconfdir}
cp -rf %{devenvdir}/bin/* %{_bindir}

# Move over new http configurations
cp -rf %{devenvdir}/httpd/* %{libradir}
cp -rf %{devenvdir}/httpd.conf %{sitedir}/httpd/
cp -rf %{devenvdir}/httpd.conf %{brokerdir}/httpd/
cp -f %{devenvdir}/client.cfg %{devenvdir}/server.cfg /etc/mcollective
mkdir -p %{sitedir}/httpd/logs
mkdir -p %{sitedir}/httpd/run
mkdir -p %{brokerdir}/httpd/logs
mkdir -p %{brokerdir}/httpd/run
ln -s %{sitedir}/public/* %{htmldir}
ln -s /usr/lib64/httpd/modules/ %{sitedir}/httpd/modules
ln -s /usr/lib64/httpd/modules/ %{brokerdir}/httpd/modules

# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root %{devenvdir}/crontab

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
%{devenvdir}/etc/qpidd.conf
%{devenvdir}/etc/qpid/pki
%{devenvdir}/etc/qpid/qpidc.conf
%{devenvdir}/etc/httpd/conf.d/000000_default.conf
%{devenvdir}/init.d/libra-broker
%{devenvdir}/init.d/libra-site
%{devenvdir}/etc/libra/controller.conf
%{devenvdir}/etc/libra/node.conf
%{devenvdir}/etc/openshift/express.conf
%{devenvdir}/etc/sysconfig/iptables
%{devenvdir}/bin/li-log-util
%{devenvdir}/client.cfg
%{devenvdir}/crontab
%{devenvdir}/devenv.spec
%{devenvdir}/httpd/broker/httpd/broker.conf
%{devenvdir}/httpd.conf
%{devenvdir}/httpd/site/httpd/site.conf
%{devenvdir}/httpd/site/public/robots.txt
%{devenvdir}/li-devenv.sh
%{devenvdir}/qpid/make-certs.sh
%{devenvdir}/server.cfg


%changelog
* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Changed source file structure to remove 'devenv' dir

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Spec cleanup

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial restructuring
